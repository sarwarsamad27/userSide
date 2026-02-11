import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/connectivity_plus.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/view/auth/loginView.dart';
import 'package:user_side/viewModel/provider/authProvider/signUp_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customTextFeld.dart';
import 'package:user_side/widgets/customValidation.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            CustomBgContainer(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Consumer<SignUpProvider>(
                      builder: (context, provider, child) {
                        return CustomAppContainer(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 30.h,
                          ),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: provider.submitted
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_rounded,
                                  size: 70.sp,
                                  color: AppColor.primaryColor,
                                ),
                                SizedBox(height: 18.h),

                                Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.textPrimaryColor,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  "Join us and start your journey today!",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColor.textSecondaryColor
                                        .withOpacity(0.8),
                                  ),
                                ),
                                SizedBox(height: 30.h),

                                // Email
                                CustomTextField(
                                  headerText: "Email Address",
                                  hintText: "Enter your email",
                                  controller: emailController,
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.email,
                                ),
                                SizedBox(height: 18.h),

                                // Password
                                CustomTextField(
                                  headerText: "Password",
                                  hintText: "Enter your password",
                                  controller: passwordController,
                                  isPassword: true,
                                  prefixIcon: Icons.lock_outline,
                                  validator: (v) => Validators.minLen(
                                    v,
                                    6,
                                    label: "Password",
                                  ),
                                ),
                                SizedBox(height: 18.h),

                                // Confirm Password
                                CustomTextField(
                                  headerText: "Confirm Password",
                                  hintText: "Re-enter your password",
                                  controller: confirmPasswordController,
                                  isPassword: true,
                                  prefixIcon: Icons.lock_reset_outlined,
                                  validator: (v) {
                                    final val = (v ?? "").trim();
                                    if (val.isEmpty)
                                      return "Confirm Password is required";
                                    if (val != passwordController.text.trim()) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 25.h),

                                CustomButton(
                                  text: provider.loading
                                      ? "Please Wait..."
                                      : "Create Account",
                                  onTap: provider.loading
                                      ? null
                                      : () async {
                                          provider.clearError();

                                          if (!provider.submitted) {
                                            provider.setSubmitted(true);
                                          }

                                          if (!(_formKey.currentState
                                                  ?.validate() ??
                                              false)) {
                                            return;
                                          }

                                          if (!await isConnected()) {
                                            if (mounted)
                                              PremiumToast.error(
                                                context,
                                                "No internet connection",
                                              );
                                            return;
                                          }

                                          await provider.signUpProvider(
                                            email: emailController.text.trim(),
                                            password: passwordController.text
                                                .trim(),
                                          );

                                          if (provider.signUpData?.message ==
                                              "User registered successfully") {
                                            // Check if success field varies
                                            // Ideally check code_status or similar
                                            emailController.clear();
                                            passwordController.clear();
                                            confirmPasswordController.clear();
                                            provider.setSubmitted(false);

                                            if (!mounted) return;
                                            PremiumToast.success(
                                              context,
                                              "Registration Successful",
                                            );

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const LoginScreen(),
                                              ),
                                            );
                                          } else {
                                            if (mounted) {
                                              PremiumToast.error(
                                                context,
                                                provider.errorMessage ??
                                                    "Signup Failed",
                                              );
                                            }
                                          }
                                        },
                                ),

                                SizedBox(height: 25.h),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: AppColor.blackcolor,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                      ),
                                      child: Text(
                                        "Or continue with",
                                        style: TextStyle(
                                          color: AppColor.textSecondaryColor,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: AppColor.blackcolor,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20.h),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account? ",
                                      style: TextStyle(
                                        color: AppColor.textSecondaryColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          color: AppColor.textPrimaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Loader
            Consumer<SignUpProvider>(
              builder: (context, value, child) {
                if (value.loading) {
                  return Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.3),
                    child: Utils.loadingLottie(size: 80),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
