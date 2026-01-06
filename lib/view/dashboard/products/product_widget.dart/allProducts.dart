import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/viewModel/provider/productProvider/getAllProduct_provider.dart';
import 'package:user_side/widgets/productCard.dart';

class AllProducts extends StatelessWidget {
  const AllProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      sliver: Consumer<GetAllProductProvider>(
        builder: (context, provider, child) {
          final products = provider.filteredProducts;

          if (provider.loading && products.isEmpty) {
            return SliverToBoxAdapter(
              child: Center(
                child: SpinKitThreeBounce(
                  color: AppColor.primaryColor,
                  size: 30.0,
                ),
              ),
            );
          }

          return SliverGrid(

            delegate: SliverChildBuilderDelegate(
              
              
              (context, index) {
              // Safety check
              if (index >= products.length) {
                return const SizedBox();
              }

              final product = products[index];

              final imageUrl =
                  (product.images != null && product.images!.isNotEmpty)
                  ? product.images!.first
                  : ''; // empty instead of placeholder

              return ProductCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        profileId: product.profileId ?? "",
                        categoryId: product.categoryId ?? "",
                        productId: product.productId ?? "",
                      ),
                    ),
                  );
                },
                imageUrl: imageUrl.isNotEmpty
                    ? (imageUrl.startsWith('http')
                          ? Global.imageUrl + imageUrl
                          : imageUrl)
                    : '', // pass empty to show icon in ProductCard
                price: "${product.afterDiscountPrice ?? 0}",
                name: product.name ?? "",
                description: product.description ?? "",
                saveText: "${product.discountPercentage ?? 0}% OFF",

                averageRating: product.averageRating ?? 0.0,
                originalPrice: "${product.beforeDiscountPrice ?? 0}",
              );
            }, childCount: products.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              mainAxisExtent: 260.h,
            ),
          );
        },
      ),
    );
  }
}
