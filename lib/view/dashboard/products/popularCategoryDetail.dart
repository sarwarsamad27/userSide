import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/allProducts.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/searchBar_categoryList.dart';
import 'package:user_side/widgets/customStickyHeader.dart';

class PopularCategoryDetailScreen extends StatelessWidget {
  const PopularCategoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                minHeight: 130.h,
                maxHeight: 130.h,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: SearchbarCategorylist(),
                ),
              ),
            ),
           
            AllProducts(),
          ],
        ),
      ),
    );
  }
}
