import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/addToCartButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/buyNowButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfileScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productImage.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/review.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
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
    context.read<GetSingleProductProvider>().fetchSingleProduct(
      widget.profileId,
      widget.categoryId,
      widget.productId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetSingleProductProvider>();

    if (provider.loading || provider.productData == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }

    final data = provider.productData!;
    final product = data.product!;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⭐ IMAGES Dynamic
                  ProductImage(imageUrls: product.images ?? []),

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
                                      logoUrl: data.profileImage ?? "",
                                      bannerUrl: "",
                                    ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 24.r,
                                backgroundImage: data.profileImage != null
                                    ? NetworkImage(data.profileImage!)
                                    : AssetImage(
                                            "assets/images/shookoo_image.png",
                                          )
                                          as ImageProvider,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              data.profileName ?? "",
                              style: TextStyle(
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
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // ⭐ Product Price
                        Text(
                          "Rs: ${product.afterDiscountPrice ?? 0}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // ⭐ Colors
                        Text(
                          "Select Color",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
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
                                color: selected ? Colors.white : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 20.h),

                        // ⭐ Sizes
                        Text(
                          "Select Size",
                          style: TextStyle(
                            fontSize: 16.sp,
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
                                color: selected ? Colors.white : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 20.h),

                        // ⭐ DESCRIPTION Dynamic
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        Text(
                          product.description ?? "",
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.5,
                            fontSize: 14.sp,
                          ),
                        ),

                        SizedBox(height: 20.h),

                        Review(),
                      ],
                    ),
                  ),
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
                      itemCount: relatedProducts.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (context, index) {
                        final item = relatedProducts[index];
                        return SizedBox(
                          width: 175.w,
                          child: ProductCard(
                            name: item['name']!,
                            price: item['price']!,
                            imageUrl: item['imageUrl']!,
                            onTap: () {},
                          ),
                        );
                      },
                    ),
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
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: otherProducts.length,
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
                      final item = otherProducts[index];
                      return ProductCard(
                        name: item['name']!,
                        price: item['price']!,
                        imageUrl: item['imageUrl']!,
                        onTap: () {},
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
                    imageUrls: [],
                    name: '',
                    description: '',
                    price: '',
                    brandName: '',
                  ),
                  SizedBox(width: 12.w),
                  BuyNowButton(
                    imageUrls: [],
                    name: '',
                    description: '',
                    price: '',
                    brandName: '',
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
