import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryAndProduct/categoryScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/productTile.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularCategory_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularProduct_provider.dart';

class PopularProductAndCategory extends StatefulWidget {
  const PopularProductAndCategory({super.key});

  @override
  State<PopularProductAndCategory> createState() =>
      _PopularProductAndCategoryState();
}

class _PopularProductAndCategoryState extends State<PopularProductAndCategory> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //------------------ POPULAR CATEGORY -------------------//
            Text(
              "Popular Category",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),

            Consumer<PopularCategoryProvider>(
              builder: (context, provider, _) {
                // Initial loader only
                if (provider.loading && provider.allCategories.isEmpty) {
                  return Utils.shoppingLoadingLottie(size: 80);
                }

                final items = provider.allCategories;

                if (items.isEmpty) {
                  return Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Utils.notFound(),
                            Text("No Categories Found"),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                final columnCount = (items.length / 2).ceil();

                return SizedBox(
                  height: 280.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: columnCount,
                    itemBuilder: (context, index) {
                      final start = index * 2;
                      final end = start + 2;

                      final columnItems = items.sublist(
                        start,
                        end > items.length ? items.length : end,
                      );

                      return Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: Column(
                          children: columnItems.map((item) {
                            return CustomProductTile(
                              imageUrl:
                                  //  item.categoryImage != null
                                  Global.imageUrl + item.categoryImage!,
                              name: item.categoryName ?? "",
                              saveText:
                                  "Save upto: ${(item.averageDiscountPercentage ?? 0).toStringAsFixed(0)}%",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Categoryscreen(
                                      profileId: item.profileId ?? '',
                                      categoryId: item.categoryId ?? '',
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            Text(
              "Popular Products",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),

            Consumer<PopularProductProvider>(
              builder: (context, provider, _) {
                // Initial loader only
                if (provider.loading &&
                    (provider.popularProducts?.products == null ||
                        provider.popularProducts!.products!.isEmpty)) {
                  return Utils.shoppingLoadingLottie(size: 80);
                }

                final products = provider.popularProducts?.products ?? [];

                if (products.isEmpty) {
                  return Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Utils.notFound(size: 200),
                            Text("No products found"),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                final columnCount = (products.length / 2).ceil();

                return SizedBox(
                  height: 300.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: columnCount,
                    itemBuilder: (context, index) {
                      final start = index * 2;
                      final end = start + 2;

                      final columnProducts = products.sublist(
                        start,
                        end > products.length ? products.length : end,
                      );

                      return Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: Column(
                          children: columnProducts.map((product) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: CustomProductTile(
                                imageUrl: product.image != null
                                    ? Global.imageUrl + product.image!
                                    : "",
                                name: product.name ?? '',
                                price: "Rs ${product.afterDiscountPrice ?? 0}",
                                discountText:
                                    "Save Rs ${product.discountAmount ?? 0}",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                        profileId: product.profileId ?? '',
                                        categoryId: product.categoryId ?? '',
                                        productId: product.productId ?? '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
