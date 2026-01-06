import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/view/auth/forgotScreen.dart';
import 'package:user_side/view/auth/signUpScreen.dart';
import 'package:user_side/view/dashboard/homeScreen.dart';
import 'package:user_side/viewModel/provider/authProvider/login_provider.dart';
import 'package:user_side/viewModel/provider/authProvider/signInWithGoogle_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customTextFeld.dart';
import 'package:user_side/widgets/social_button.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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

                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// App Logo
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

                            CustomTextField(
                              headerText: "Email Address",
                              hintText: "Enter your email",
                              controller: provider.emailController,
                              prefixIcon: Icons.email_outlined,
                            ),
                            SizedBox(height: 18.h),

                            CustomTextField(
                              headerText: "Password",
                              hintText: "Enter your password",
                              controller: provider.passwordController,
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
                            ),
                            SizedBox(height: 12.h),

                            /// Forgot Password
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

                            /// Login Button
                            CustomButton(
                              text: "Login",
                              onTap: () async {
                                provider.clearError();

                                await provider.loginProvider(
                                  email: provider.emailController.text.trim(),
                                  password: provider.passwordController.text
                                      .trim(),
                                );

                                if (provider.loginData?.token != null &&
                                    provider.loginData!.token!.isNotEmpty) {
                                  provider.emailController.text.trim();

                                  provider.emailController.clear();
                                  provider.passwordController.clear();

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

                            /// Divider
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

                            /// Login with Google / Apple Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                socialButton(
                                  icon: FontAwesomeIcons.google,
                                  color: Colors.redAccent,
                                  onTap: () async {
                                    final provider =
                                        Provider.of<GoogleLoginProvider>(
                                          context,
                                          listen: false,
                                        );
                                    await provider.loginWithGoogle();

                                    if (provider.loginData?.token != null &&
                                        provider.loginData!.token!.isNotEmpty) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HomeNavBarScreen(),
                                        ),
                                      );
                                    } else {
                                      AppToast.error(
                                        provider.errorMessage ??
                                            "Google login failed",
                                      );
                                      print(
                                        "Google login failed: ${provider.errorMessage}",
                                      );
                                    }
                                  },
                                ),
                                SizedBox(width: 25.w),
                                socialButton(
                                  icon: Icons.apple,
                                  color: Colors.black,
                                  onTap: () => print("Apple login"),
                                ),
                              ],
                            ),

                            SizedBox(height: 25.h),

                            /// Sign Up Link
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
