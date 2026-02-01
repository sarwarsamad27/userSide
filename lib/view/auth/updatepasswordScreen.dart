import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/view/auth/loginView.dart';
import 'package:user_side/viewModel/provider/authProvider/updatePassword_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customTextFeld.dart';
import 'package:user_side/widgets/customValidation.dart';

class UpdatePasswordScreen extends StatefulWidget {
  final String email;
  const UpdatePasswordScreen({super.key, required this.email});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UpdatePasswordProvider>();

    return WillPopScope(
      onWillPop: () async {
        AppToast.error("Please update your password");
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: CustomBgContainer(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 24.w,
                      right: 24.w,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 30.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomAppContainer(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 50.h,
                              ),
                              child: Form(
                                key: _formKey,
                                autovalidateMode: _submitted
                                    ? AutovalidateMode.onUserInteraction
                                    : AutovalidateMode.disabled,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 20.h),

                                    Text(
                                      "Update Password",
                                      style: TextStyle(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.primaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 10.h),

                                    Text(
                                      "Your new password must be different from previously used passwords.",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black54,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 50.h),

                                    CustomTextField(
                                      headerText: "New Password",
                                      hintText: "Enter new password",
                                      controller: newPasswordController,
                                      prefixIcon: Icons.lock_outline,
                                      isPassword: true,
                                      validator: (v) =>
                                          Validators.minLen(v, 6, label: "Password"),
                                    ),
                                    SizedBox(height: 30.h),

                                    CustomTextField(
                                      headerText: "Confirm Password",
                                      hintText: "Re-enter new password",
                                      controller: confirmPasswordController,
                                      prefixIcon: Icons.lock_outline,
                                      isPassword: true,
                                      validator: (v) {
                                        final val = (v ?? "").trim();
                                        if (val.isEmpty) return "Confirm Password is required";
                                        if (val != newPasswordController.text.trim()) {
                                          return "Passwords do not match";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 20.h),

                                    Text(
                                      "Make sure both passwords match.",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.black45,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 25.h),

                                    /// ✅ Optional: show provider error under button (audit-friendly)
                                    if ((provider.errorMessage ?? "").isNotEmpty) ...[
                                      Text(
                                        provider.errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12.sp,
                                          height: 1.2,
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                    ],

                                    CustomButton(
                                      text: provider.loading ? "Updating..." : "Update Password",
                                      onTap: provider.loading
                                          ? null
                                          : () async {
                                              provider.clearError();

                                              if (!_submitted) {
                                                setState(() => _submitted = true);
                                              }

                                              final ok =
                                                  _formKey.currentState?.validate() ?? false;
                                              if (!ok) return;

                                              final success =
                                                  await context.read<UpdatePasswordProvider>().updatePassword(
                                                        email: widget.email,
                                                        newPassword:
                                                            newPasswordController.text.trim(),
                                                      );

                                              if (!success) {
                                                // Provider error already set; toast optional
                                                AppToast.error(
                                                  provider.errorMessage ??
                                                      "Update failed. Please try again.",
                                                );
                                                return;
                                              }

                                              // ✅ success
                                              final msg = provider.updateData?.message ??
                                                  "Password updated successfully.";
                                              AppToast.success(msg);

                                              newPasswordController.clear();
                                              confirmPasswordController.clear();

                                              if (!mounted) return;
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const LoginScreen(),
                                                ),
                                              );
                                            },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
