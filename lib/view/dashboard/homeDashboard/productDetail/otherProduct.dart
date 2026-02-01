import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/widgets/premiumSurface.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/otherProduct_provider.dart';
import 'package:user_side/widgets/productCard.dart';

class OtherProductsSection extends StatelessWidget {
  const OtherProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: const SectionHeader(title: "Other Products"),
        ),
        SizedBox(height: 10.h),
        Consumer<OtherProductProvider>(
          builder: (context, op, child) {
            if (op.loading) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Center(
                  child: SpinKitThreeBounce(
                    color: AppColor.primaryColor,
                    size: 30.0,
                  ),
                ),
              );
            }

            if (op.otherModel == null ||
                op.otherModel!.otherProducts == null ||
                op.otherModel!.otherProducts!.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: const EmptyStateText(text: "No other products"),
              );
            }

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: op.otherModel!.otherProducts!.length,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6.w,
                mainAxisSpacing: 4.h,
                childAspectRatio: 0.67,
              ),
              itemBuilder: (context, index) {
                final item = op.otherModel!.otherProducts![index];
                return ProductCard(
                  name: item.name ?? "",
                  price: "${item.afterDiscountPrice ?? 0}",
                  originalPrice: item.beforeDiscountPrice != null
                      ? "${item.beforeDiscountPrice}"
                      : null,
                  averageRating: item.averageRating != null
                      ? item.averageRating!.toDouble()
                      : 0.0,
                  saveText: item.beforeDiscountPrice != null
                      ? "Save Rs.${(item.beforeDiscountPrice! - item.afterDiscountPrice!).abs()}"
                      : null,
                  description: item.description ?? "",
                  imageUrl: (item.images != null && item.images!.isNotEmpty)
                      ? item.images!.first
                      : "",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          profileId: item.profileId ?? "",
                          categoryId: item.categoryId ?? "",
                          productId: item.sId ?? "",
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
