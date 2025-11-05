import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/view/dashboard/products/popularCategoryDetail.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/productTile.dart';

class PopularProductAndCategory extends StatelessWidget {
  PopularProductAndCategory({super.key});

  final List<Map<String, String>> popularProducts = [
    {
      "image": "https://picsum.photos/200/300",
      "name": "Stylish Jacket",
      "price": "\$49.99",
    },
    {
      "image": "https://picsum.photos/200/301",
      "name": "Classic Watch",
      "price": "\$79.99",
    },
    {
      "image": "https://picsum.photos/200/302",
      "name": "Running Shoes",
      "price": "\$59.99",
    },
    {
      "image": "https://picsum.photos/200/303",
      "name": "Leather Bag",
      "price": "\$89.99",
    },
    {
      "image": "https://picsum.photos/200/300",
      "name": "Stylish Jacket",
      "price": "\$49.99",
    },
    {
      "image": "https://picsum.photos/200/301",
      "name": "Classic Watch",
      "price": "\$79.99",
    },
    {
      "image": "https://picsum.photos/200/302",
      "name": "Running Shoes",
      "price": "\$59.99",
    },
    {
      "image": "https://picsum.photos/200/303",
      "name": "Leather Bag",
      "price": "\$89.99",
    },
    {
      "image": "https://picsum.photos/200/300",
      "name": "Stylish Jacket",
      "price": "\$49.99",
    },
    {
      "image": "https://picsum.photos/200/301",
      "name": "Classic Watch",
      "price": "\$79.99",
    },
    {
      "image": "https://picsum.photos/200/302",
      "name": "Running Shoes",
      "price": "\$59.99",
    },
    {
      "image": "https://picsum.photos/200/303",
      "name": "Leather Bag",
      "price": "\$89.99",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------- Popular Category -----------
            Text(
              "Popular Category",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),

            SizedBox(
              height: 290.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (popularProducts.length / 2).ceil(),
                itemBuilder: (context, index) {
                  final startIndex = index * 2;
                  final endIndex = startIndex + 2;
                  final columnProducts = popularProducts.sublist(
                    startIndex,
                    endIndex > popularProducts.length
                        ? popularProducts.length
                        : endIndex,
                  );

                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: columnProducts.map((product) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: CustomProductTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PopularCategoryDetailScreen(),
                                ),
                              );
                            },
                            imageUrl: product["image"]!,
                            name: product["name"]!,
                            // price: product["price"]!,
                            // 👇 Optional badges (call where needed)
                            // discountText: "20% OFF",
                            saveText: "Save Rs: 500",
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            // ----------- Popular Products -----------
            Text(
              "Popular Products",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),

            SizedBox(
              height: 290.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (popularProducts.length / 2).ceil(),
                itemBuilder: (context, index) {
                  final startIndex = index * 2;
                  final endIndex = startIndex + 2;
                  final columnProducts = popularProducts.sublist(
                    startIndex,
                    endIndex > popularProducts.length
                        ? popularProducts.length
                        : endIndex,
                  );

                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: columnProducts.map((product) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: CustomProductTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    imageUrls: [
                                      product['image']!,

                                      product['image']!,
                                      product['image']!,
                                      product['image']!,
                                      product['image']!,
                                    ],
                                    name: product["name"]!,
                                    description:
                                        "Its is very much good condition",
                                    price: product["price"]!,
                                    brandName: "brandName",
                                  ),
                                ),
                              );
                            },
                            imageUrl: product["image"]!,
                            name: product["name"]!,
                            price: product["price"]!,
                            // 👇 Optional (show only if needed)
                            discountText: "15% OFF",
                            // saveText: "Save 300 Rupees",
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            Text(
              "All Products",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
