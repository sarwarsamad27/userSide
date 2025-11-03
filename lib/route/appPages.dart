// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:user_side/route/routes.dart';

class Routes {
  static Route<MaterialPageRoute>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash
      case RoutesName.splashScreen:
        return pushTo(const Column());
      //  case RoutesName.loginScreen:
      //     return pushTo(const LoginScreen());
      //  case RoutesName.companyHomeScreen:
      //     return pushTo(const CompanyHomeScreen());
      //  case RoutesName.categoryScreen:
      //     return pushTo(const CategoryScreen());
      //  case RoutesName.addCategoryScreen:
      //     return pushTo(const AddCategoryScreen());
      //  case RoutesName.categoryDetailScreen:
      //     return pushTo(const CategoryProductsScreen ());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());
      //  case RoutesName.splashScreen:
      //     return pushTo(const SplashScreen());

      default:
        return pushTo(
          const Scaffold(body: Center(child: Text("No Route Defined"))),
        );
    }
  }

  static Route<MaterialPageRoute<dynamic>>? pushTo(Widget screen) =>
      MaterialPageRoute(builder: (context) => screen);
}
