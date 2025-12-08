import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/addToFavourite_provider.dart';
import 'package:user_side/widgets/customButton.dart';

class AddToCart extends StatelessWidget {
  final String productId;
  final List<String> selectedSizes;
  final List<String> selectedColors;

  AddToCart({
    super.key,
    required this.selectedColors,
    required this.selectedSizes,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<AddToFavouriteProvider>(
        builder: (context, provider, _) => CustomButton(
          second: true,
          text: provider.loading ? "Adding..." : "Add to Favourite",
          onTap: () async {
            if (selectedColors.isEmpty || selectedSizes.isEmpty) {
              AppToast.warning("Please select both color and size");
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

            /// ⭐ Handle backend messages properly
            if (response.success == true) {
              AppToast.success(
                response.message ?? "Added to favourite successfully",
              );
            } else {
              AppToast.error(response.message ?? "Failed to add to favourite");
            }
          },
        ),
      ),
    );
  }
}
