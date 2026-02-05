import 'package:flutter/material.dart';
import 'package:user_side/models/auth/forgotPassword_model.dart';
import 'package:user_side/viewModel/repository/authRepository/forgotPassword_repository.dart';

class ForgotProvider with ChangeNotifier {
  final ForgotPasswordRepository repository = ForgotPasswordRepository();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ForgotPasswordModel? _forgotData;
  ForgotPasswordModel? get forgotData => _forgotData;

  bool _submitted = false;
  bool get submitted => _submitted;

  void setSubmitted(bool value) {
    _submitted = value;
    notifyListeners();
  }

  Future<void> forgotPassword({required String email}) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.isEmpty) {
      _errorMessage = "Email is required";
      _loading = false;
      notifyListeners();
      return;
    }

    final response = await repository.forgotPassword(email);

    _loading = false;

    if (response != null && response.message != null) {
      _forgotData = response;
    } else {
      _errorMessage = "Something went wrong";
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _submitted = false;
    notifyListeners();
  }
}
