  // Getters
  bool get isLoading => _isLoading;
  LoginFormStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get rememberCredentials => _rememberCredentials;

  // Setters
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set status(LoginFormStatus value) {
    _status = value;
    notifyListeners();
  }

  set errorMessage(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  set rememberCredentials(bool value) {
    _rememberCredentials = value;
    notifyListeners();
  }

  // Reset form to initial state
  void reset() {
    email = '';
    password = '';
    _isLoading = false;
    _status = LoginFormStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }

  // Function to handle session expiry
  void handleSessionExpired() {
    _status = LoginFormStatus.sessionExpired;
    _errorMessage = 'Su sesión ha expirado. Por favor inicie sesión nuevamente.';
    notifyListeners();
  }

  // Validate form with detailed error messages
  bool isValidForm() {
    bool isValid = formkey.currentState?.validate() ?? false;
    
    // Additional validation beyond the form validators
    if (isValid) {
      // Email validation
      if (!isValidEmail(email)) {
        _errorMessage = 'Por favor ingrese un correo electrónico válido.';
        return false;
      }
      
      // Password validation
      if (!isValidPassword(password)) {
        _errorMessage = 'La contraseña debe tener al menos 8 caracteres.';
        return false;
      }
      
      // Clear error message if validation passes
      _errorMessage = '';
    }
    
    return isValid;
  }
  
  // Email validator
  bool isValidEmail(String email) {
    // Regular expression for basic email validation
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }
  
  // Password validator
  bool isValidPassword(String password) {
    return password.length >= 8;
  }
  
  // Set error state with a message
  void setError(String message) {
    _status = LoginFormStatus.error;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
  
  // Set success state
  void setSuccess() {
    _status = LoginFormStatus.success;
    _isLoading = false;
    notifyListeners();
  }
  
  // Set submitting state
  void setSubmitting() {
    _status = LoginFormStatus.submitting;
    _isLoading = true;
    notifyListeners();
  }
