import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/addToCartButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/buyNowButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfileScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productImage.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/review.dart';
import 'package:user_side/widgets/productCard.dart';

class ProductDetailScreen extends StatefulWidget {
  final List<String> imageUrls;
  final String name;
  final String description;
  final String price;
  final String brandName;

  const ProductDetailScreen({
    super.key,
    required this.imageUrls,
    required this.name,
    required this.description,
    required this.price,
    required this.brandName,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<String> selectedColors = [];
  List<String> selectedSizes = [];

  // ⭐ PROPER REVIEW SYSTEM
 
 
  final List<String> availableColors = ["Red", "Blue", "Black", "White"];
  final List<String> availableSizes = ["S", "M", "L", "XL"];

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImage(imageUrls: widget.imageUrls),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 18.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ───────────────── Brand Section ────────────────
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CompanyProfileScreen(
                                      companyName: widget.name,
                                      logoUrl: "https://picsum.photos/100/100",
                                      bannerUrl:
                                          "https://picsum.photos/800/300",
                                    ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 24.r,
                                backgroundImage: AssetImage(
                                  "assets/images/shookoo_image.png",
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              widget.brandName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // ───────────────── Title + Price ────────────────
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Rs: ${widget.price}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ───────────────── Color Selection ────────────────
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
                          children: availableColors.map((color) {
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
                                color: selected ? Colors.white : Colors.black87,
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.h),

                        // ───────────────── Size Selection ────────────────
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
                          children: availableSizes.map((size) {
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
                                color: selected ? Colors.white : Colors.black87,
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.h),

                        // ───────────────── Description ────────────────
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        Text(
                          widget.description,
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.5,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 20.h),

                     Review()],
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
                    imageUrls: widget.imageUrls,
                    name: widget.name,
                    description: widget.description,
                    price: widget.price,
                    brandName: widget.brandName,
                  ),
                  SizedBox(width: 12.w),
                  BuyNowButton(
                    imageUrls: widget.imageUrls,
                    name: widget.name,
                    description: widget.description,
                    price: widget.price,
                    brandName: widget.brandName,
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
