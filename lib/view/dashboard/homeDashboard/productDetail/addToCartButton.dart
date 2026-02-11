import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/view/auth/loginView.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/addToFavourite_provider.dart';
import 'package:user_side/widgets/customButton.dart';

class AddToCart extends StatelessWidget {
  final String productId;
  final List<String> selectedSizes;
  final List<String> selectedColors;
  final bool productHasColors;
  final bool productHasSizes;

  final String stockStatus;

  const AddToCart({
    super.key,
    required this.productId,
    required this.selectedColors,
    required this.selectedSizes,
    required this.productHasColors,
    required this.productHasSizes,
    required this.stockStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    final bool isOutOfStock =
        stockStatus.trim().toLowerCase() == "out of stock";

    return Consumer<AddToFavouriteProvider>(
      builder: (context, provider, _) {
        if (!isLoggedIn) {
          return CustomButton(
            second: true,
            text: "Login Required",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          );
        }

        return CustomButton(
          second: true,
          text: isOutOfStock
              ? "Out of Stock"
              : (provider.loading ? "Adding..." : "Add to Favourite"),

          // ✅ disable when out of stock OR when loading
          onTap: (isOutOfStock || provider.loading)
              ? null
              : () async {
                  // 🔥 VALIDATION ONLY IF OPTION EXISTS
                  if ((productHasColors && selectedColors.isEmpty) ||
                      (productHasSizes && selectedSizes.isEmpty)) {
                    AppToast.warning("Please select required options");
                    return;
                  }

                  await provider.addToFavourite(
                    productId: productId,
                    selectedSizes: selectedSizes,
                    selectedColors: selectedColors,
                  );

                  final response = provider.favouriteResponse;
                  if (response == null) {
                    AppToast.error("Something went wrong");
                    return;
                  }

                  if (response.success == true) {
                    if (context.mounted) Utils.showAddToCartLottie(context);
                  } else {
                    AppToast.error(
                      response.message ?? "Failed to add to favourite",
                    );
                  }
                },
        );
      },
    );
  }
}
