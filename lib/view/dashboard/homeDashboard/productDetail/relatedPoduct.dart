import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/widgets/premiumSurface.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/relatedProduct_provider.dart';
import 'package:user_side/widgets/productCard.dart';

class RelatedProductsSection extends StatelessWidget {
  const RelatedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RelatedProductProvider>(
      builder: (context, rp, child) {
        if (rp.loading) {
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

        if (rp.relatedModel == null ||
            rp.relatedModel!.relatedProducts == null ||
            rp.relatedModel!.relatedProducts!.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const EmptyStateText(text: "No related products"),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: "Related Products"),
              SizedBox(height: 10.h),
              SizedBox(
                height: 250.h,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: rp.relatedModel!.relatedProducts!.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final item = rp.relatedModel!.relatedProducts![index];

                    return SizedBox(
                      width: 190.w,
                      child: ProductCard(
                        name: item.name ?? "",
                        price: "${item.afterDiscountPrice ?? 0}",
                        originalPrice: item.beforeDiscountPrice != null
                            ? "${item.beforeDiscountPrice}"
                            : null,
                        description: item.description ?? "",
                        discountText: item.discountPercentage != null
                            ? "${item.discountPercentage}% OFF"
                            : null,
                        saveText: item.beforeDiscountPrice != null
                            ? "Save Rs.${(item.beforeDiscountPrice! - item.afterDiscountPrice!).abs()}"
                            : null,
                        imageUrl:
                            (item.images != null && item.images!.isNotEmpty)
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
