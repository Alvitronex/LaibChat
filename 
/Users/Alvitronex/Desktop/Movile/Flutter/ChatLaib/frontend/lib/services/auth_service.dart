class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  User? _user;
  String? _token;
  DateTime? _tokenExpiry;
  String? _deviceId;
  Timer? _tokenExpiryTimer;

  bool get authenticated => _isLoggedIn;
  User get user => _user!;
  Servidor servidor = Servidor();

  // Secure storage with AES encryption
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  // Check if token exists and is valid
  Future<void> checkAuth() async {
    final token = await _storage.read(key: 'token');
    final expiryString = await _storage.read(key: 'token_expiry');
    final deviceId = await _storage.read(key: 'device_id');
    
    if (token != null && expiryString != null) {
      final expiry = DateTime.parse(expiryString);
      // If token is expired, force logout
      if (expiry.isBefore(DateTime.now())) {
        await forceLogout(expired: true);
        return;
      }
      
      _deviceId = deviceId;
      // Set timer to handle token expiration
      _setExpiryTimer(expiry);
      await tryToken(token);
    }
  }

  // Set timer to logout when token expires
  void _setExpiryTimer(DateTime expiry) {
    final timeToExpiry = expiry.difference(DateTime.now());
    _tokenExpiryTimer?.cancel();
    _tokenExpiryTimer = Timer(timeToExpiry, () {
      forceLogout(expired: true);
    });
  }

  // Login with proper token rotation and session invalidation
  Future<String> login(
    String email,
    String password,
    String deviceName,
  ) async {
    // Clear any existing tokens before login attempt
    await cleanUp(silent: true);
    
    try {
      // Generate unique device identifier for session tracking
      _deviceId = '${deviceName}_${DateTime.now().millisecondsSinceEpoch}';
      
      final response =
          await http.post(Uri.parse('${servidor.baseUrl}/sanctum/token'),
              body: ({
                'email': email,
                'password': password,
                'device_name': _deviceId,
              }));

      if (response.statusCode == 200) {
        String token = response.body.toString();
        
        // Store device ID for session tracking
        await _storage.write(key: 'device_id', value: _deviceId);
        
        // Calculate token expiry (default: 24 hours from now)
        _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
        await _storage.write(key: 'token_expiry', value: _tokenExpiry!.toIso8601String());
        
        // Set timer for automatic logout on expiry
        _setExpiryTimer(_tokenExpiry!);
        
        await tryToken(token);
        return "correcto";
      } else if (response.statusCode == 401) {
        return 'Credenciales inválidas';
      } else {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? 'Error de autenticación';
      }
    } catch (e) {
      return 'Error de conexión: ${e.toString()}';
    }
  }
  Future<bool> tryToken(String? token) async {
    if (token == null) {
      return false;
    } else {
      try {
        final response = await http.get(
          Uri.parse('${servidor.baseUrl}/user'),
          headers: {'Authorization': 'Bearer $token'}
        );
        
        if (response.statusCode == 200) {
          _isLoggedIn = true;
          _user = User.fromJson(jsonDecode(response.body));
          _token = token;
          await storeToken(token);
          notifyListeners();
          return true;
        } else {
          // Token is invalid, clean up
          await cleanUp(silent: true);
          return false;
        }
      } catch (e) {
        print('Token validation error: $e');
        await cleanUp(silent: true);
        return false;
      }
    }
  }

  Future<void> storeToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }
  
  // Check if token is about to expire and refresh it if needed
  Future<bool> refreshTokenIfNeeded() async {
    if (_tokenExpiry != null) {
      // If token will expire in less than 30 minutes, refresh it
      if (_tokenExpiry!.difference(DateTime.now()).inMinutes < 30) {
        try {
          final response = await http.post(
            Uri.parse('${servidor.baseUrl}/refresh-token'),
            headers: {'Authorization': 'Bearer $_token'}
          );
          
          if (response.statusCode == 200) {
            final newToken = response.body.toString();
            _token = newToken;
            
            // Update expiry time (extend by 24 hours)
            _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
            await _storage.write(key: 'token_expiry', value: _tokenExpiry!.toIso8601String());
            await storeToken(newToken);
            
            // Reset expiry timer
            _setExpiryTimer(_tokenExpiry!);
            return true;
          }
        } catch (e) {
          print('Token refresh error: $e');
        }
      } else {
        // Token is still valid
        return true;
      }
    }
    return false;
  }
  // Safe logout with proper token revocation
  Future<bool> logout() async {
    if (_token == null) {
      await cleanUp();
      return true;
    }
    
    try {
      final response = await http.get(
        Uri.parse('${servidor.baseUrl}/user/revoke'),
        headers: {'Authorization': 'Bearer $_token'}
      );
      
      if (response.statusCode == 200) {
        // Token successfully revoked on server
        await cleanUp();
        notifyListeners();
        return true;
      } else {
        // Server failed to revoke token, don't clear local state yet
        return false;
      }
    } catch (e) {
      print('Logout error: $e');
      // If server is unreachable, perform local logout but inform user
      await cleanUp(serverError: true);
      return false;
    }
  }
  
  // Force logout (for security or when token expires)
  Future<void> forceLogout({bool expired = false, bool serverError = false}) async {
    await cleanUp(expired: expired, serverError: serverError);
    notifyListeners();
  }

  // Clean up all authentication data
  Future<void> cleanUp({bool silent = false, bool expired = false, bool serverError = false}) async {
    // Cancel token expiry timer
    _tokenExpiryTimer?.cancel();
    _tokenExpiryTimer = null;
    
    _user = null;
    _isLoggedIn = false;
    _token = null;
    _tokenExpiry = null;
    
    // Clear all secure storage
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'token_expiry');
    await _storage.delete(key: 'device_id');
    
    if (!silent) {
      notifyListeners();
      
      // Additional handling based on reason for cleanup
      if (expired) {
        // Handle expired token scenario (could emit an event/notification)
        print('Session expired. Please login again.');
      } else if (serverError) {
        // Handle server error during logout
        print('Warning: You are logged out locally, but there was an error communicating with the server.');
      }
    }
  }
  
  // Validate the current session
  Future<bool> validateSession() async {
    if (_token == null) return false;
    
    try {
      // First check if token needs refresh
      if (!(await refreshTokenIfNeeded())) {
        return false;
      }
      
      final response = await http.get(
        Uri.parse('${servidor.baseUrl}/validate-session'),
        headers: {'Authorization': 'Bearer $_token', 'Device-Id': _deviceId ?? ''}
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Session validation error: $e');
      return false;
    }
  }
