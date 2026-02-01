import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/view/auth/forgotScreen.dart';
import 'package:user_side/view/auth/signUpScreen.dart';
import 'package:user_side/view/dashboard/DashboardScreen.dart';
import 'package:user_side/viewModel/provider/authProvider/login_provider.dart';
import 'package:user_side/viewModel/provider/authProvider/signInWithGoogle_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customTextFeld.dart';
import 'package:user_side/widgets/customValidation.dart';
import 'package:user_side/widgets/social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _submitted = false; // ✅ add this

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: AppColor.appimagecolor,
            resizeToAvoidBottomInset: true,
            body: CustomBgContainer(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: CustomAppContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 30.h,
                      ),

                      /// ✅ Form autovalidate only after submit
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _submitted
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
                              "Welcome Back 👋",
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.textPrimaryColor,
                              ),
                            ),
                            SizedBox(height: 6.h),

                            Text(
                              "Login to continue your journey",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColor.textSecondaryColor.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),

                            /// ✅ Email
                            CustomTextField(
                              headerText: "Email Address",
                              hintText: "Enter your email",
                              controller: provider.emailController,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              // ❌ REMOVE autovalidateMode here
                              validator: Validators.email,
                            ),
                            SizedBox(height: 18.h),

                            /// ✅ Password
                            CustomTextField(
                              headerText: "Password",
                              hintText: "Enter your password",
                              controller: provider.passwordController,
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
                              // ❌ REMOVE autovalidateMode here
                              validator: (v) =>
                                  Validators.minLen(v, 6, label: "Password"),
                            ),
                            SizedBox(height: 12.h),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ForgotScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: AppColor.textPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),

                            /// ✅ Login Button
                            CustomButton(
                              text: provider.loading
                                  ? "Please wait..."
                                  : "Login",
                              onTap: provider.loading
                                  ? null
                                  : () async {
                                      provider.clearError();

                                      // ✅ enable validation only after first submit
                                      if (!_submitted) {
                                        setState(() => _submitted = true);
                                      }

                                      final ok =
                                          _formKey.currentState?.validate() ??
                                          false;
                                      if (!ok) return;

                                      await provider.loginProvider();

                                      if (provider.loginData?.token != null &&
                                          provider
                                              .loginData!
                                              .token!
                                              .isNotEmpty) {
                                        provider.emailController.clear();
                                        provider.passwordController.clear();

                                        if (!mounted) return;
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => HomeNavBarScreen(),
                                          ),
                                        );
                                      } else {
                                        AppToast.error(
                                          provider.errorMessage ??
                                              "Invalid email or password",
                                        );
                                      }
                                    },
                            ),

                            SizedBox(height: 20.h),

                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.withOpacity(0.4),
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
                                    color: Colors.grey.withOpacity(0.4),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                socialButton(
                                  icon: FontAwesomeIcons.google,
                                  color: Colors.redAccent,
                                  onTap: () async {
                                    final googleProvider =
                                        Provider.of<GoogleLoginProvider>(
                                          context,
                                          listen: false,
                                        );
                                    await googleProvider.loginWithGoogle();

                                    if (googleProvider.loginData?.token !=
                                            null &&
                                        googleProvider
                                            .loginData!
                                            .token!
                                            .isNotEmpty) {
                                      if (!mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HomeNavBarScreen(),
                                        ),
                                      );
                                    } else {
                                      AppToast.error(
                                        googleProvider.errorMessage ??
                                            "Google login failed",
                                      );
                                    }
                                  },
                                ),
                                SizedBox(width: 25.w),
                                socialButton(
                                  icon: Icons.apple,
                                  color: Colors.black,
                                  onTap: () => debugPrint("Apple login"),
                                ),
                              ],
                            ),

                            SizedBox(height: 25.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don’t have an account? ",
                                  style: TextStyle(
                                    color: AppColor.textSecondaryColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: AppColor.textPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
