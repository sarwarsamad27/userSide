import 'package:flutter/material.dart';
import 'package:user_side/viewModel/provider/authProvider/forgotPassword_provider.dart';
import 'package:user_side/viewModel/provider/authProvider/login_provider.dart';
import 'package:user_side/viewModel/provider/authProvider/signUp_provider.dart';
import 'package:user_side/viewModel/provider/authProvider/updatePassword_provider.dart';
import 'package:user_side/viewModel/provider/authProvider/verifyCode_provider.dart';
import 'package:provider/provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllCategoryProfileWise_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllProductCategoryWise_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllProfile_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';

class AppMultiProvider extends StatelessWidget {
  final Widget child;
  const AppMultiProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ForgotProvider()),
        ChangeNotifierProvider(create: (_) => VerifyCodeProvider()),
        ChangeNotifierProvider(create: (_) => UpdatePasswordProvider()),
        ChangeNotifierProvider(create: (_) => GetAllProfileProvider()),
        ChangeNotifierProvider(
          create: (_) => GetAllCategoryProfileWiseProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GetAllProductCategoryWiseProvider(),
        ),
        ChangeNotifierProvider(create: (_) => GetSingleProductProvider()),
      ],
      child: child,
    );
  }
}
