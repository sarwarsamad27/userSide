import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/view/auth/verifyCodeScreen.dart';
import 'package:user_side/viewModel/provider/authProvider/forgotPassword_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customTextFeld.dart';
import 'package:user_side/widgets/customValidation.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: CustomBgContainer(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Consumer<ForgotProvider>(
                    builder: (context, provider, child) {
                      return CustomAppContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 70.h,
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: provider.submitted
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 20.h),
                              Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "Don’t worry! It happens. Please enter the email address associated with your account.",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 40.h),

                              CustomTextField(
                                headerText: "Email Address",
                                hintText: "Enter your email",
                                controller: emailController,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email,
                              ),
                              SizedBox(height: 30.h),

                              Text(
                                "We will send you a code to reset your password.",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black45,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20.h),

                              CustomButton(
                                text: provider.loading ? "Sending..." : "Next",
                                onTap: provider.loading
                                    ? null
                                    : () async {
                                        provider.clearError();

                                        if (!provider.submitted) {
                                          provider.setSubmitted(true);
                                        }

                                        if (!(_formKey.currentState
                                                ?.validate() ??
                                            false))
                                          return;

                                        await provider.forgotPassword(
                                          email: emailController.text.trim(),
                                        );

                                        if (provider.forgotData != null &&
                                            provider.forgotData!.message ==
                                                "Verification code sent to your email") {
                                          provider.setSubmitted(false);

                                          if (!mounted) return;
                                          PremiumToast.success(
                                            context,
                                            provider.forgotData!.message!,
                                          );

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => VerifyCodeScreen(
                                                email: emailController.text
                                                    .trim(),
                                              ),
                                            ),
                                          );
                                        } else {
                                          if (mounted) {
                                            PremiumToast.error(
                                              context,
                                              provider.errorMessage ??
                                                  provider
                                                      .forgotData
                                                      ?.message ??
                                                  "Error occurred",
                                            );
                                          }
                                        }
                                      },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
