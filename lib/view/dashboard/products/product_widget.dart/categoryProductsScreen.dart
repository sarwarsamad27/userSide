import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/categoryWiseProduct.dart';

/// Standalone "see all" screen for one category — reuses the same grid
/// widget shown when a category chip is selected on the main product screen.
class CategoryProductsScreen extends StatelessWidget {
  final String category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          category,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: CategoryWiseProductsWidget(category: category),
      ),
    );
  }
}
