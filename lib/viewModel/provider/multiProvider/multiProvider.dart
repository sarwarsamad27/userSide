import 'package:flutter/material.dart';
import 'package:user_side/viewModel/provider/authProvider/forgotPassword_provider.dart';
import 'package:user_side/viewModel/provider/authProvider/login_provider.dart';
import 'package:user_side/viewModel/provider/authProvider/signUp_provider.dart';
import 'package:user_side/viewModel/provider/authProvider/updatePassword_provider.dart';
import 'package:user_side/viewModel/provider/authProvider/verifyCode_provider.dart';
import 'package:provider/provider.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/addToFavourite_provider.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/getFavourite_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllCategoryProfileWise_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllProductCategoryWise_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllProfile_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/otherProduct_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/recommendedProduct_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/relatedProduct_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/createOrder_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/getMyOrder_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/categoryWiseProduct_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/createReview_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getAllProduct_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularCategory_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularProduct_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/reviewEditOrDelete_provider.dart';

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
        ChangeNotifierProvider(create: (_) => CreateOrderProvider()),
        ChangeNotifierProvider(create: (_) => AddToFavouriteProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteProvider()),
        ChangeNotifierProvider(create: (_) => PopularProductProvider()),
        ChangeNotifierProvider(create: (_) => PopularCategoryProvider()),
        ChangeNotifierProvider(create: (_) => GetAllProductProvider()),
        ChangeNotifierProvider(create: (_) => CreateReviewProvider()),
        ChangeNotifierProvider(create: (_) => ReviewActionProvider()),
        ChangeNotifierProvider(create: (_) => RelatedProductProvider()),
        ChangeNotifierProvider(create: (_) => OtherProductProvider()),
        ChangeNotifierProvider(create: (_) => GetMyOrderProvider()),
        ChangeNotifierProvider(create: (_) => GetCategoryWiseProductProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
      ],
      child: child,
    );
  }
}
