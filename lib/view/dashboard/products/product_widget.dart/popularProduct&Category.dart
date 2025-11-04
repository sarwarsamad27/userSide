import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return   SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Popular Category",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 280.h,
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
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        child: Image.network(
                                          product["image"]!,
                                          height: 100.h,
                                          width: 100.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      FittedBox(
                                        child: Text(
                                          product["name"]!,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                    Text(
                      "Popular Products",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 280.h,
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
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        child: Image.network(
                                          product["image"]!,
                                          height: 100.h,
                                          width: 100.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      FittedBox(
                                        child: Text(
                                          product["name"]!,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
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
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );

  }
}