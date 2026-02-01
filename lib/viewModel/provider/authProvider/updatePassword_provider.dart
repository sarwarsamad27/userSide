import 'package:flutter/material.dart';
import 'package:user_side/models/auth/updatePassword_model.dart';
import 'package:user_side/resources/connectivity_plus.dart';
import 'package:user_side/viewModel/repository/authRepository/updatePassword_repository.dart';

class UpdatePasswordProvider with ChangeNotifier {
  final UpdatePasswordRepository repository = UpdatePasswordRepository();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UpdatePasswordModel? _updateData;
  UpdatePasswordModel? get updateData => _updateData;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    clearError();
    _updateData = null;

    // ✅ Basic guards (extra safety)
    if (email.trim().isEmpty) {
      _errorMessage = "Email is required.";
      notifyListeners();
      return false;
    }
    if (newPassword.trim().length < 6) {
      _errorMessage = "Password must be at least 6 characters.";
      notifyListeners();
      return false;
    }

    // ✅ Internet check
    final connected = await isConnected();
    if (!connected) {
      _errorMessage = "No internet connection. Please try again.";
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      final resp = await repository.updatePassword(email, newPassword);

      _updateData = resp;

      // ✅ Decide success based on API response structure
      final msg = resp.message?.trim();
      final success = msg != null && msg.isNotEmpty;

      if (!success) {
        _errorMessage = "Update failed. Please try again.";
      }

      return success;
    } catch (e) {
      // ✅ Generic catch (socket, timeout, unexpected)
      _errorMessage = "Something went wrong. Please try again.";
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
