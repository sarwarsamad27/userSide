import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customTextFeld.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _api = NetworkApiServices();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final response = await _api.postApi(Global.ChangeLoggedInPassword, {
      'currentPassword': _currentCtrl.text,
      'newPassword': _newCtrl.text,
    });
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['code_status'] == false) {
      PremiumToast.error(
        context,
        response['message']?.toString() ?? 'Could not change password',
      );
      return;
    }

    PremiumToast.success(context, 'Password changed successfully');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        title: Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                headerText: "Current Password",
                hintText: "Enter your current password",
                controller: _currentCtrl,
                isPassword: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Enter your current password" : null,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                headerText: "New Password",
                hintText: "Enter a new password",
                controller: _newCtrl,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter a new password";
                  if (v.length < 6) return "Minimum 6 characters";
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                headerText: "Confirm New Password",
                hintText: "Re-enter the new password",
                controller: _confirmCtrl,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Confirm your new password";
                  if (v != _newCtrl.text) return "Passwords do not match";
                  return null;
                },
              ),
              SizedBox(height: 28.h),
              CustomButton(
                text: "Update Password",
                loading: _isLoading,
                onTap: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
