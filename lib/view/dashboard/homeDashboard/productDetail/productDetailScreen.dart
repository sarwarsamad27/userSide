import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/addToCartButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/buyNowButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfileScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productImage.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/review/review.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/otherProduct_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/relatedProduct_provider.dart';
import 'package:user_side/widgets/productCard.dart';

class ProductDetailScreen extends StatefulWidget {
  final String profileId;
  final String categoryId;
  final String productId;

  ProductDetailScreen({
    super.key,
    required this.profileId,
    required this.categoryId,
    required this.productId,
  });
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<String> selectedColors = [];
  List<String> selectedSizes = [];
  final relatedProducts = [
    {
      'name': 'Running Shoes',
      'price': '4,999',
      'imageUrl':
          'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
    },
    {
      'name': 'Sneakers',
      'price': '6,499',
      'imageUrl':
          'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
    },
    {
      'name': 'Sports Jacket',
      'price': '8,999',
      'imageUrl':
          'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
    },
  ];
  final otherProducts = [
    {
      'name': 'T-Shirt',
      'price': '2,999',
      'imageUrl':
          'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
    },
    {
      'name': 'Joggers',
      'price': '3,499',
      'imageUrl':
          'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
    },
    {
      'name': 'Cap',
      'price': '999',
      'imageUrl':
          'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetSingleProductProvider>().fetchSingleProduct(
        widget.profileId,
        widget.categoryId,
        widget.productId,
      );

      context.read<RelatedProductProvider>().fetchRelatedProducts(
        widget.productId,
        widget.categoryId,
      );

      context.read<OtherProductProvider>().fetchOtherProducts(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetSingleProductProvider>();

    if (provider.loading || provider.productData == null) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Center(
            child: SpinKitThreeBounce(
                          color: AppColor.primaryColor, 
                          size: 30.0,
                        ),
          ),
        ),
      );
    }

    final data = provider.productData!;
    if (data.product == null) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Center(
            child: Text(
              "Product not found",
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        ),
      );
    }

    final product = data.product!;

    log(data.profileImage.toString());
    int currentImageIndex = 0;
    String currentImage = product.images != null && product.images!.isNotEmpty
        ? product.images!.first
        : '';
    final before = product.beforeDiscountPrice ?? 0;
    final after = product.afterDiscountPrice ?? 0;

    int discountPercent = 0;

    if (before > 0 && after > 0 && before > after) {
      discountPercent = (((before - after) / before) * 100).round();
    }
    String getValidImageUrl(String? url) {
      if (url == null) return '';
      if (url.startsWith('http')) return url; // already full URL
      return Global.imageUrl + url; // relative path
    }

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImage(
                    imageUrls: product.images ?? [],
                    onImageChange: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 18.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⭐ BRAND SECTION Dynamic
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CompanyProfileScreen(
                                      companyName: data.profileName ?? "",
                                      logoUrl:
                                          Global.imageUrl + data.profileImage!,
                                      profileId: data.product!.profileId ?? "",
                                      categoryId:
                                          data.product!.categoryId ?? "",
                                      description:
                                          data.profileDescription ?? "",
                                      phoneNumber:
                                          data.profilephoneNumber ?? "",
                                      email: data.profileEmail ?? "",
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(2), // border width
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColor
                                        .primaryColor, // ⭐ yahan apna color do
                                    width: 1, // ⭐ border thickness
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 24.r,
                                  backgroundImage: data.profileImage != null
                                      ? NetworkImage(
                                          getValidImageUrl(data.profileImage),
                                        )
                                      : const AssetImage("") as ImageProvider,
                                ),
                              ),
                            ),

                            SizedBox(width: 12.w),
                            Text(
                              data.profileName ?? "",
                              style: TextStyle(
                                color: AppColor.blackcolor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // ⭐ Product Name
                        Text(
                          product.name ?? "",
                          style: TextStyle(
                            color: AppColor.primaryColor,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // ⭐ Product Price
                        Row(
                          children: [
                            Text(
                              "Rs: ${product.afterDiscountPrice ?? 0}",
                              style: TextStyle(
                                color: AppColor.successColor,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "Rs: ${product.beforeDiscountPrice ?? 0}",
                              style: TextStyle(
                                color: AppColor.errorColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "$discountPercent% OFF",
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 16.h),
                        Text(
                          "Description:",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: AppColor.blackcolor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          product.description ?? "",
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.5,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ⭐ Colors
                        Text(
                          "Select Color:",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.blackcolor,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        Wrap(
                          spacing: 8.w,
                          children: (product.color ?? []).map((color) {
                            final selected = selectedColors.contains(color);
                            return ChoiceChip(
                              label: Text(color),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  selected
                                      ? selectedColors.remove(color)
                                      : selectedColors.add(color);
                                });
                              },
                              selectedColor: AppColor.primaryColor,
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColor.primaryColor,
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 20.h),

                        // ⭐ Sizes
                        Text(
                          "Select Size:",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColor.blackcolor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        Wrap(
                          spacing: 8.w,
                          children: (product.size ?? []).map((size) {
                            final selected = selectedSizes.contains(size);
                            return ChoiceChip(
                              label: Text(size),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  selected
                                      ? selectedSizes.remove(size)
                                      : selectedSizes.add(size);
                                });
                              },
                              selectedColor: AppColor.primaryColor,
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColor.primaryColor,
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 20.h),

                        Consumer<GetSingleProductProvider>(
                          builder: (_, provider, __) {
                            return Review(
                              productId: product.sId ?? '',
                              reviews: provider.productData?.reviews ?? [],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Consumer<RelatedProductProvider>(
                    builder: (context, rp, child) {
                      if (rp.loading) {
                        return Center(
                          child: SpinKitThreeBounce(
                          color: AppColor.primaryColor, 
                          size: 30.0,
                        ),
                        );
                      }

                      if (rp.relatedModel == null ||
                          rp.relatedModel!.relatedProducts == null ||
                          rp.relatedModel!.relatedProducts!.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            "No related products",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              "Related Products",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            height: 240.h,
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  rp.relatedModel!.relatedProducts!.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: 12.w),
                              itemBuilder: (context, index) {
                                final item =
                                    rp.relatedModel!.relatedProducts![index];

                                return SizedBox(
                                  width: 175.w,
                                  child: ProductCard(
                                    name: item.name ?? "",
                                    price: "${item.afterDiscountPrice ?? 0}",
                                    originalPrice:
                                        item.beforeDiscountPrice != null
                                        ? "${item.beforeDiscountPrice}"
                                        : null,
                                    description: item.description ?? "",
                                    discountText:
                                        item.discountPercentage != null
                                        ? "${item.discountPercentage}% OFF"
                                        : null,
                                    imageUrl:
                                        (item.images != null &&
                                            item.images!.isNotEmpty)
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
                      );
                    },
                  ),

                  // ───────────────── Other Products ────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    child: Text(
                      "Other Products",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Consumer<OtherProductProvider>(
                    builder: (context, op, child) {
                      if (op.loading) {
                        return Center(
                          child: SpinKitThreeBounce(
                          color: AppColor.primaryColor, 
                          size: 30.0,
                        ),
                        );
                      }

                      if (op.otherModel == null ||
                          op.otherModel!.otherProducts == null ||
                          op.otherModel!.otherProducts!.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            "No other products",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: op.otherModel!.otherProducts!.length,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final item = op.otherModel!.otherProducts![index];
                          return ProductCard(
                            name: item.name ?? "",
                            price: "${item.afterDiscountPrice ?? 0}",
                            originalPrice: item.beforeDiscountPrice != null
                                ? "${item.beforeDiscountPrice}"
                                : null,
                            description: item.description ?? "",
                            discountText: item.discountPercentage != null
                                ? "${item.discountPercentage}% OFF"
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
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // ───────────────── Bottom Buttons ────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                children: [
                  AddToCart(
                    selectedColors: selectedColors,
                    selectedSizes: selectedSizes,
                    productId: product.sId ?? '',
                  ),

                  SizedBox(width: 12.w),

                  BuyNowButton(
                    imageUrls: product.images ?? [],
                    name: product.name ?? '',
                    description: product.description ?? '',
                    price: '${product.afterDiscountPrice ?? 0}',
                    brandName: data.profileName ?? '',
                    selectedColors: selectedColors,
                    selectedSizes: selectedSizes,
                    selectedImage: currentImage,
                    productId: product.sId ?? '',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
