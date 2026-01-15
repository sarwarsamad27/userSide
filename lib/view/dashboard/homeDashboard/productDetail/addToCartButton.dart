import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/addToFavourite_provider.dart';
import 'package:user_side/widgets/customButton.dart';

class AddToCart extends StatelessWidget {
  final String productId;
  final List<String> selectedSizes;
  final List<String> selectedColors;
  final bool productHasColors;
  final bool productHasSizes;

  // ✅ NEW
  final String stockStatus;

  const AddToCart({
    super.key,
    required this.productId,
    required this.selectedColors,
    required this.selectedSizes,
    required this.productHasColors,
    required this.productHasSizes,
    required this.stockStatus, // ✅ NEW
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock =
        stockStatus.trim().toLowerCase() == "out of stock";

    return Expanded(
      child: Consumer<AddToFavouriteProvider>(
        builder: (context, provider, _) => CustomButton(
          second: true,
          text: isOutOfStock
              ? "Out of Stock"
              : (provider.loading ? "Adding..." : "Add to Favourite"),

          // ✅ IMPORTANT: disable when out of stock OR when loading
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
          AppToast.success(
            response.message ?? "Added to favourite successfully",
          );
        } else {
          AppToast.error(
            response.message ?? "Failed to add to favourite",
          );
        }
      },
 )
        
      ),
    );
  }
}
