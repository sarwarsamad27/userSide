import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/addToCartButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/buyNowButton.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/productDetailUI_provider.dart';

class BottomActionBar extends StatelessWidget {
  final String productId;
  final List<String> imageUrls;
  final String name;
  final String description;
  final String price;
  final String brandName;
  final String stockStatus;

  /// 🔥 NEW (API based flags)
  final bool productHasColors;
  final bool productHasSizes;

  const BottomActionBar({
    super.key,
    required this.productId,
    required this.imageUrls,
    required this.name,
    required this.description,
    required this.price,
    required this.brandName,
    required this.productHasColors,
    required this.productHasSizes,
    required this.stockStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailUiProvider>(
      builder: (context, ui, _) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
            decoration: BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                AddToCart(
                  productId: productId,
                  selectedColors: ui.selectedColors,
                  selectedSizes: ui.selectedSizes,
                  productHasColors: productHasColors,
                  productHasSizes: productHasSizes,
                   stockStatus: stockStatus, 
                ),
                SizedBox(width: 12.w),
                BuyNowButton(
                  productId: productId,
                  name: name,
                  price: price,
                  selectedImage: ui.currentImage,
                  selectedColors: ui.selectedColors,
                  selectedSizes: ui.selectedSizes,
                  productHasColors: productHasColors,
                  productHasSizes: productHasSizes,
                  stockStatus: stockStatus,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
