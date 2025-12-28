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

  const BottomActionBar({
    super.key,
    required this.productId,
    required this.imageUrls,
    required this.name,
    required this.description,
    required this.price,
    required this.brandName,
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
            decoration: BoxDecoration(
              color: Colors.transparent,

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.r),
                topRight: Radius.circular(22.r),
              ),
            ),
            child: Row(
              children: [
                AddToCart(
                  selectedColors: ui.selectedColors,
                  selectedSizes: ui.selectedSizes,
                  productId: productId,
                ),
                SizedBox(width: 12.w),
                BuyNowButton(
                  imageUrls: imageUrls,
                  name: name,
                  description: description,
                  price: price,
                  brandName: brandName,
                  selectedColors: ui.selectedColors,
                  selectedSizes: ui.selectedSizes,
                  selectedImage: ui.currentImage,
                  productId: productId,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
