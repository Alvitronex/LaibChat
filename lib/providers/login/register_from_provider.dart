import 'package:flutter/material.dart';

class registerfromprovider extends ChangeNotifier {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String confirmedPassword = '';
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    return formkey.currentState?.validate() ?? false;
  }
}
