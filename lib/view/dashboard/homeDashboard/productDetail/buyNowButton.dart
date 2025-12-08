import 'package:flutter/material.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productBuyForm.dart';
import 'package:user_side/widgets/customButton.dart';

class BuyNowButton extends StatelessWidget {
  final List<String> imageUrls;
  final String name;
  final String description;
  final String price;
  final String brandName;
  final String productId;

  final List<String> selectedColors;
  final List<String> selectedSizes;
  final String selectedImage;

  BuyNowButton({
    super.key,
    required this.imageUrls,
    required this.name,
    required this.description,
    required this.price,
    required this.brandName,
    required this.selectedColors,
    required this.selectedSizes,
    required this.selectedImage,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomButton(
       
        text: "Buy Now",
        onTap: () {
          final selectedColor = selectedColors.isNotEmpty
              ? selectedColors.first
              : null;
          final selectedSize = selectedSizes.isNotEmpty
              ? selectedSizes.first
              : null;

          if (selectedColor == null || selectedSize == null) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Select Options"),
                content: const Text(
                  "Please select both color and size before proceeding.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          } else {
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
