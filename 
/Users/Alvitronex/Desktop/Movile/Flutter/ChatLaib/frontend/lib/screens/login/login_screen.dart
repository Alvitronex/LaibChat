// Define an enum for authentication states to better manage UI
enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  failed,
  sessionExpired
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthStatus _authStatus = AuthStatus.initial;
  String _errorMessage = '';
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Check for any existing session on screen initialization
    _checkExistingSession();
    
    // Listen for auth state changes (like session expiry)
    _setupAuthListener();
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
  
  // Setup listener for authentication state changes
  void _setupAuthListener() {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Listen for authentication status changes (like token expiry)
    _authSubscription = authService.addListener(() {
      if (!authService.authenticated && mounted) {
        // If we're on the login screen and authentication was lost, show appropriate message
        if (_authStatus == AuthStatus.authenticated) {
          setState(() {
            _authStatus = AuthStatus.sessionExpired;
            _errorMessage = 'Su sesión ha expirado. Por favor inicie sesión nuevamente.';
          });
          
          _showErrorDialog(_errorMessage);
        }
      }
    });
  }
  
  // Check if there's an existing valid session
  Future<void> _checkExistingSession() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Check for stored token and validate it
    await authService.checkAuth();
    
    if (authService.authenticated) {
      // If we have a valid session, navigate to home
      if (mounted) {
        _navigateToHome();
      }
    }
  }
  
  // Navigate to home screen, replacing the login screen
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Home(),
      ),
    );
  }
  
  // Show error dialog for authentication issues
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _DialogoAlerta(mensaje: message),
    );
  }
  
  // Show a snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
              if (_authStatus == AuthStatus.sessionExpired)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade800),
                    textAlign: TextAlign.center,
                  ),
                ),
              Center(
                child: ChangeNotifierProvider(
                  create: (_) => loginformprovider(),
                  child: _LoginForm(
                    onLoginSuccess: _navigateToHome,
                    onLoginError: (message) {
                      setState(() {
                        _authStatus = AuthStatus.failed;
                        _errorMessage = message;
                      });
                      _showSnackBar(message, isError: true);
                    },
                  ),
                ),
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => loginForm.email = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su correo electrónico';
              }
              if (!loginForm.isValidEmail(value)) {
                return 'Ingrese un correo electrónico válido';
              }
              return null;
            },
            enabled: loginForm.status != LoginFormStatus.submitting,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: Icon(Icons.email),
              suffixIcon: loginForm.email.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        loginForm.email = '';
                      });
                    },
                  )
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _obscurePassword = true;
  
  @override
  Widget build(BuildContext context) {
          TextFormField(
            autocorrect: false,
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            onChanged: (value) => loginForm.password = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su contraseña';
              }
              if (value.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              return null;
            },
            enabled: loginForm.status != LoginFormStatus.submitting,
            decoration: InputDecoration(
              labelText: 'C          ),
          const SizedBox(height: 15),
          
          // Remember me checkbox
          Row(
            children: [
              Checkbox(
                value: loginForm.rememberCredentials,
                onChanged: (value) {
                  setState(() {
                    loginForm.rememberCredentials = value ?? false;
                  });
                },
              ),
              const Text('Recordar credenciales'),
              
              const Spacer(),
              
              // Password recovery link
              TextButton          MaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.blue,
            onPressed: loginForm.status == LoginFormStatus.submitting
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    
                    // Validate form
                    if (!loginForm.isValidForm()) {
                      // Show validation error if any
                      if (loginForm.errorMessage.isNotEmpty) {
                        _showErrorSnackBar(loginForm.errorMessage);
                      }
                      return;
                    }
                    
                    // Set form to submitting state
                    loginForm.setSubmitting();
                    
                    try {
                      // Get auth service
                      final authService =
                          Provider.of<AuthService>(context, listen: false);
                      
                      // Generate a unique device identifier
                      final deviceId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';
                      
                      // Attempt login
                      String respuesta = await authService.login(
                          loginForm.email, loginForm.password, deviceId);
                      
                      // Handle login response
                      if (respuesta == "correcto") {
                        // Check if session is valid
                        if (await authService.validateSession()) {
                          // Set success state
                          loginForm.setSuccess();
                          
                          // Call success callback if provided
                          if (widget.o            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              child: loginForm.status == LoginFormStatus.submitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Iniciando sesión...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : const Text(
                      'Ingresar',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to handle form status changes
  void _handleStatusChanges(loginformprovider loginForm) {
    // Set up status-based actions
    switch (loginForm.status) {
      case LoginFormStatus.sessionExpired:
        // Show session expired message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSessionExpiredDialog(loginForm.errorMessage);
        });
        break;
      case LoginFormStatus.error:
        // Error is displayed via the error container in the UI
        break;
      default:
        // Other states don't need special handling
        break;
    }
  
    return Form(
      key: loginForm.formkey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error message display
          if (loginForm.status == LoginFormStatus.error || 
              loginForm.status == LoginFormStatus.sessionExpired)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                loginForm.errorMessage,
                style: TextStyle(color: Colors.red.shade800),
                textAlign: TextAlign.center,
              ),
            ),
          
          SizedBox(
            height: 20,
          ),
      ],
    );
  }
}
