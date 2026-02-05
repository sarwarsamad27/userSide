import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/addToCartButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/buyNowButton.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/productDetailUI_provider.dart';

class BottomActionBar extends StatelessWidget {
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

  final String productId;
  final List<String> imageUrls; 
  final String name;
  final String description;
  final String price;
  final String brandName;
  final String stockStatus;
  final bool productHasColors;
  final bool productHasSizes;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Consumer<ProductDetailUiProvider>(
        builder: (context, ui, _) {
          return Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: AddToCart(
                    productId: productId,
                    selectedColors: ui.selectedColors,
                    selectedSizes: ui.selectedSizes,
                    productHasColors: productHasColors,
                    productHasSizes: productHasSizes,
                    stockStatus: stockStatus,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: BuyNowButton(
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
