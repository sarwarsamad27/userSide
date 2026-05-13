import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/categoryWiseProduct.dart';
import 'package:user_side/viewModel/provider/productProvider/categoryWiseProduct_provider.dart';

/// Shows ALL products across every store for a given category name.
/// Uses the keyword-based /buyer/category endpoint so "shoes" matches
/// sneakers, boots, sandals etc. from any seller.
class CategoryAllProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryAllProductsScreen({super.key, required this.categoryName});

  @override
  State<CategoryAllProductsScreen> createState() =>
      _CategoryAllProductsScreenState();
}

class _CategoryAllProductsScreenState extends State<CategoryAllProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetCategoryWiseProductProvider>().fetchCategoryProducts(
        widget.categoryName,
        refresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColor.primaryColor,
        onRefresh: () async {
          context.read<GetCategoryWiseProductProvider>().fetchCategoryProducts(
            widget.categoryName,
            refresh: true,
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryWiseProductsWidget(category: widget.categoryName),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }
}
