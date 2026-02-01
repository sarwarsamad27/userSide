import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/toast.dart';
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
  bool _submitted = false;

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
    final providerWatch = context.watch<ForgotProvider>(); // ✅ listen loading

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
                  child: CustomAppContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 70.h,
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
                            text: providerWatch.loading ? "Sending..." : "Next",
                            onTap: providerWatch.loading
                                ? null
                                : () async {
                                    final provider = context
                                        .read<ForgotProvider>();

                                    if (!_submitted) {
                                      setState(() => _submitted = true);
                                    }

                                    final ok =
                                        _formKey.currentState?.validate() ??
                                        false;
                                    if (!ok) return;

                                    await provider.forgotPassword(
                                      email: emailController.text.trim(),
                                    );

                                    if (provider.forgotData != null &&
                                        provider.forgotData!.message ==
                                            "Verification code sent to your email") {
                                      AppToast.success(
                                        provider.forgotData!.message!,
                                      );

                                      if (!mounted) return;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VerifyCodeScreen(
                                            email: emailController.text.trim(),
                                          ),
                                        ),
                                      );
                                    } else {
                                      AppToast.error(
                                        provider.errorMessage ??
                                            provider.forgotData?.message ??
                                            "Error occurred",
                                      );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
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
