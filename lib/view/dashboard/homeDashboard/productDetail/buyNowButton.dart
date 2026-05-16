import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productBuyForm.dart';

class BuyNowButton extends StatelessWidget {
  final String productId;
  final String name;
  final String price;
  final String selectedImage;
  final String stockStatus;
  final int? quantity;
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
    this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock =
        stockStatus.trim().toLowerCase() == "out of stock" ||
        (quantity != null && quantity! <= 0);

    return GestureDetector(
      onTap: isOutOfStock
          ? null
          : () {
              if ((productHasColors && selectedColors.isEmpty) ||
                  (productHasSizes && selectedSizes.isEmpty)) {
                AppToast.warning(
                  "Please select required options",
                  context: context,
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductBuyForm(
                    imageUrl: Global.getImageUrl(selectedImage),
                    name: name,
                    price: price,
                    colors: selectedColors,
                    sizes: selectedSizes,
                    productId: [productId],
                  ),
                ),
              );
            },
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: isOutOfStock ? Colors.grey.shade300 : AppColor.primaryColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: isOutOfStock
              ? null
              : [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            isOutOfStock ? "Out of Stock" : "Buy Now",
            style: TextStyle(
              color: isOutOfStock ? Colors.grey.shade600 : Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
