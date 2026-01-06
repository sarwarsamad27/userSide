import 'package:flutter/material.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productBuyForm.dart';
import 'package:user_side/widgets/customButton.dart';

class BuyNowButton extends StatelessWidget {
  final String productId;
  final String name;
  final String price;
  final String selectedImage;
  final String stockStatus;
  final List<String> selectedColors;
  final List<String> selectedSizes;

  final bool productHasColors;
  final bool productHasSizes;

  const BuyNowButton({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.selectedImage,
    required this.selectedColors,
    required this.selectedSizes,
    required this.productHasColors,
    required this.productHasSizes,
    required this.stockStatus,
  });

  @override
  Widget build(BuildContext context) {
    final String s = stockStatus.trim().toLowerCase();
    final bool isOutOfStock = s == "out of stock";
    return Expanded(
      child: CustomButton(
        text: "Buy Now",
        onTap: () {
          if (isOutOfStock) {
            null;
          } else {
            if ((productHasColors && selectedColors.isEmpty) ||
                (productHasSizes && selectedSizes.isEmpty)) {
              AppToast.warning("Please select required options");
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductBuyForm(
                  imageUrl: Global.imageUrl + selectedImage,
                  name: name,
                  price: price,
                  colors: selectedColors,
                  sizes: selectedSizes,
                  productId: [productId],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
