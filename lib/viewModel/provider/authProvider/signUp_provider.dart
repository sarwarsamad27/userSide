import 'package:flutter/material.dart';
import 'package:user_side/models/auth/signUp_model.dart';
import 'package:user_side/viewModel/repository/authRepository/signUp_repository.dart';

class SignUpProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SignUpModel? _signUpData;
  SignUpModel? get signUpData => _signUpData;

  final SignUpRepository repository = SignUpRepository();

  Future<void> signUpProvider({
    required String email,
    required String password,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _signUpData = await repository.signUp(email, password);

      if (_signUpData?.newUser == null) {
        _errorMessage = _signUpData?.message ?? "Signup failed";
      }
    } catch (e) {
      _errorMessage = "Something went wrong. Please try again.";
    }

    _loading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
