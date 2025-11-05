import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/widgets/productCard.dart';

class AllProducts extends StatelessWidget {
  AllProducts({super.key});
  final List<Map<String, String>> allProducts = [
    {
      "image": "https://picsum.photos/200/304",
      "name": "Sneakers",
      "price": "39.99",
    },
    {
      "image": "https://picsum.photos/200/305",
      "name": "T-Shirt",
      "price": "19.99",
    },
    {"image": "https://picsum.photos/200/306", "name": "Cap", "price": "9.99"},
    {
      "image": "https://picsum.photos/200/307",
      "name": "Backpack",
      "price": "49.99",
    },
    {
      "image": "https://picsum.photos/200/308",
      "name": "Hoodie",
      "price": "29.99",
    },
    {
      "image": "https://picsum.photos/200/309",
      "name": "Jeans",
      "price": "59.99",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = allProducts[index];
          return ProductCard(
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
                    description: "Its is very much good condition",
                    price: product["price"]!,
                    brandName: "brandName",
                  ),
                ),
              );
            },
            imageUrl: product["image"]!,
            price: product["price"]!,
            name: product["name"]!,
            discountText: "20% OFF",
            originalPrice: "2333",
          );
        }, childCount: allProducts.length),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          mainAxisExtent: 250.h,
        ),
      ),
    );
  }
}
