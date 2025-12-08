import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryAndProduct/categoryScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/productTile.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularCategory_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularProduct_provider.dart';

class PopularProductAndCategory extends StatelessWidget {
  const PopularProductAndCategory({super.key});

  Widget buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(Icons.image_not_supported);
    }
    return Image.network(Global.imageUrl + imageUrl, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //------------------ POPULAR CATEGORY -------------------//
            Text("Popular Category",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            Consumer<PopularCategoryProvider>(
              builder: (context, provider, _) {
                if (provider.loading && provider.allCategories.isEmpty) {
                  return const Center(child: SpinKitThreeBounce(
                          color: AppColor.primaryColor, 
                          size: 30.0,
                        ),);
                }

                final items = provider.allCategories;
                final columnCount = (items.length / 2).ceil();

                return SizedBox(
                  height: 280.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: columnCount + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == columnCount) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          provider.fetchPopularCategories(loadMore: true);
                        });
                        return const Center(child: SpinKitThreeBounce(
                          color: AppColor.primaryColor, 
                          size: 30.0,
                        ),);
                      }

                      final start = index * 2;
                      final end = start + 2;

                      final columnItems =
                          items.sublist(start, end > items.length ? items.length : end);

                      return Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: Column(
                          children: columnItems.map((item) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: CustomProductTile(
                                imageUrl: item.categoryImage != null
                                    ? Global.imageUrl + item.categoryImage!
                                    : "",
                                name: item.categoryName ?? "",
                                saveText:
                                    "Save upto: ${item.averageDiscountPercentage ?? 0}%",
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

            //------------------ POPULAR PRODUCTS -------------------//
            Text("Popular Products",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            Consumer<PopularProductProvider>(
              builder: (context, provider, _) {
                if (provider.loading && provider.fetchedCount == 0) {
                  return const Center(child: SpinKitThreeBounce(
                          color: AppColor.primaryColor, 
                          size: 30.0,
                        ),);
                }

                final products = provider.popularProducts?.products ?? [];
                final columnCount = (products.length / 2).ceil();

                return SizedBox(
                  height: 290.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: columnCount + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == columnCount) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          provider.fetchPopularProducts(loadMore: true);
                        });
                        return  Center(child: SpinKitThreeBounce(
                          color: AppColor.primaryColor, 
                          size: 30.0,
                        ),);
                      }

                      final start = index * 2;
                      final end = start + 2;

                      final columnProducts = products.sublist(
                          start, end > products.length ? products.length : end);

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
