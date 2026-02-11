import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/resources/toast.dart';

class Utils {
  static Widget loadingLottie({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/loading.json',
      height: size ?? 100,
      width: size ?? 100,
    ),
  );

  static Widget shoppingLoadingLottie({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/shopping_loading.json',
      height: size ?? 200,
      width: size ?? 200,
    ),
  );

  static Widget emptyFavouriteLottie({double? size}) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/gif/empty_fav_List.json',
          height: size ?? 200,
          width: size ?? 200,
        ),
        const Text(
          "No favourites added yet",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );

  static Widget deliveryManLottie({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/delivery_man.json',
      height: size ?? 150,
      width: size ?? 150,
    ),
  );
  static Widget messageEmpty({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/no_message.json',
      height: size ?? 250,
      width: size ?? 250,
    ),
  );
  static Widget noDataFound({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/no_data_found.json',
      height: size ?? 250,
      width: size ?? 250,
    ),
  );
  static Widget notFound({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/not_found.json',
      height: size ?? 150,
      width: size ?? 150,
    ),
  );
  static Widget messageIcon({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/messageIcon.json',
      height: size ?? 150,
      width: size ?? 150,
    ),
  );

  static Widget productIcon({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/Product.json',
      height: size ?? 150,
      width: size ?? 150,
    ),
  );
  static Widget homeIcon({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/home.json',
      height: size ?? 150,
      width: size ?? 150,
    ),
  );
  static Widget favouriteIcon({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/favourite.json',
      height: size ?? 150,
      width: size ?? 150,
    ),
  );
  static Widget profileIcon({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/profile.json',
      height: size ?? 150,
      width: size ?? 150,
    ),
  );
  static Widget notificationIcons({double? size}) => Center(
    child: Lottie.asset(
      'assets/gif/notification_icon.json',
      height: size ?? 150,
      width: size ?? 150,
    ),
  );

  static void showAddToCartLottie(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/gif/add to cart.json',
              height: 200,
              width: 200,
              repeat: false,
            ),
            const SizedBox(height: 10),
            const Text(
              "Added to Favourites!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  static void showOrderSuccessLottie(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/gif/order_success.json',
              height: 300,
              width: 300,
              repeat: false,
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (Navigator.canPop(context)) {
        PremiumToast.success(context, "Order Placed Successfully");
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });
  }

  static Future<dynamic> loader(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(canPop: false, child: loadingLottie()),
    );
  }
}
