import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/view/auth/AuthLoginGate.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productBuyForm.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/getFavourite_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  String fixImage(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    return Global.imageUrl + url;
  }

  Widget buildImageOrPlaceholder(String? url, double size) {
    if (url == null || url.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Image.network(
        fixImage(url),
        height: size,
        width: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.broken_image, color: Colors.grey[600]),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Safe call after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavouriteProvider>(context, listen: false).getFavourites();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ USERID login guard (same pattern)
    return AuthGate(child: _buildScaffold(context));
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Favourites ❤️",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColor.appimagecolor,
      ),
      body: CustomBgContainer(
        child: Consumer<FavouriteProvider>(
          builder: (context, provider, _) {
            if (provider.loading) {
              return const Center(
                child: SpinKitThreeBounce(
                  color: AppColor.primaryColor,
                  size: 30.0,
                ),
              );
            }

            final favs = provider.favouriteList?.favourites ?? [];

            if (favs.isEmpty) {
              return const Center(child: Text("No favourites added"));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: favs.length,
                    itemBuilder: (context, index) {
                      final item = favs[index];
                      final beforePrice =
                          item.product?.beforeDiscountPrice ?? 0;
                      final afterPrice = item.product?.afterDiscountPrice ?? 0;
                      final qty = provider.getQuantity(index);

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: AppColor.primaryColor.withOpacity(.3),
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PRODUCT IMAGE
                            buildImageOrPlaceholder(item.product?.image, 70.h),
                            SizedBox(width: 12.w),

                            // DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.product?.name != null &&
                                      item.product!.name!.trim().isNotEmpty)
                                    Text(
                                      item.product!.name!,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                  SizedBox(height: 4.h),

                                  // SELLER INFO
                                  Row(
                                    children: [
                                      buildImageOrPlaceholder(
                                        item.seller?.image,
                                        28.h,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        item.seller?.name ?? "Seller",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),

                                  // Colors + Sizes
                                  if (item.selectedColors != null &&
                                      item.selectedColors!.isNotEmpty)
                                    Text(
                                      "Colors: ${item.selectedColors!.join(', ')}",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  if (item.selectedSizes != null &&
                                      item.selectedSizes!.isNotEmpty)
                                    Text(
                                      "Sizes: ${item.selectedSizes!.join(', ')}",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  SizedBox(height: 6.h),

                                  // PRICE + QUANTITY
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          if (beforePrice > 0)
                                            Text(
                                              "Rs. $beforePrice",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.red,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            "Rs. $afterPrice",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.successColor,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // QUANTITY
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => provider
                                                .decreaseQuantity(index),
                                            child: Container(
                                              padding: EdgeInsets.all(4.w),
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.remove,
                                                size: 16.sp,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                            ),
                                            child: Text(
                                              "$qty",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => provider
                                                .increaseQuantity(index),
                                            child: Container(
                                              padding: EdgeInsets.all(4.w),
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.add,
                                                size: 16.sp,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // DELETE ICON
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                bool deleted = await provider.deleteFavourite(
                                  index,
                                );
                                if (deleted) {
                                  AppToast.success(
                                    "this product has been removed",
                                  );
                                } else {
                                  AppToast.error("Failed to delete favourite");
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // TOTAL + CHECKOUT
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.bottomNavBarColor,
                            ),
                            onPressed: () {},
                            child: Text(
                              "Grand Total:",
                              style: TextStyle(
                                color: AppColor.blackcolor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.bottomNavBarColor,
                            ),
                            onPressed: () {},
                            child: Text(
                              "Rs. ${provider.getTotal().toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.successColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      CustomButton(
                        width: double.infinity,
                        second: true,
                        text: 'Proceed to Checkout (${favs.length})',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductBuyForm(
                                favouriteItems: favs.map((e) {
                                  return {
                                    "productId": e.product?.sId,
                                    "name": e.product?.name,
                                    "price": e.product?.afterDiscountPrice
                                        .toString(),
                                    "imageUrl": e.product?.image,
                                    "sizes": e.selectedSizes,
                                    "colors": e.selectedColors,
                                    "quantity": provider.getQuantity(
                                      favs.indexOf(e),
                                    ),
                                  };
                                }).toList(),
                                productId: favs
                                    .map((e) => e.product!.sId!)
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
