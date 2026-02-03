import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/viewModel/provider/productProvider/categoryWiseProduct_provider.dart';
import 'package:user_side/widgets/productCard.dart';

class CategoryWiseProductsWidget extends StatefulWidget {
  final String category;

  const CategoryWiseProductsWidget({super.key, required this.category});

  @override
  State<CategoryWiseProductsWidget> createState() =>
      _CategoryWiseProductsWidgetState();
}

class _CategoryWiseProductsWidgetState
    extends State<CategoryWiseProductsWidget> {
  @override
  void didUpdateWidget(covariant CategoryWiseProductsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<GetCategoryWiseProductProvider>(
          context,
          listen: false,
        ).fetchCategoryProducts(widget.category, refresh: true);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Post-frame callback ensures widget tree is built first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetCategoryWiseProductProvider>(
        context,
        listen: false,
      ).fetchCategoryProducts(widget.category, refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetCategoryWiseProductProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: SpinKitThreeBounce(
                color: AppColor.primaryColor,
                size: 30.0,
              ),
            ),
          );
        }

        if (provider.products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                "No products found in ${widget.category}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        // GridView with 2 items per row
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items in a row
            crossAxisSpacing: 4, // horizontal spacing
            mainAxisSpacing: 10, // vertical spacing
            childAspectRatio: 0.68, // adjust height/width ratio as needed
          ),
          itemBuilder: (context, index) {
            final product = provider.products[index];

            // Agar image nahi hai to empty string pass karenge
            final imageUrl =
                (product.images != null && product.images!.isNotEmpty)
                ? product.images!.first
                : '';

            return ProductCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      profileId: product.profileId ?? "",
                      categoryId: product.categoryId ?? "",
                      productId: product.sId ?? "",
                    ),
                  ),
                );
              },
              imageUrl:
                  imageUrl, // ProductCard me empty string ke liye icon show hoga
              price: "${product.afterDiscountPrice ?? 0}",
              name: product.name ?? "",
              averageRating: product.averageRating ?? 0.0,
              description: product.description ?? "",
              discountText: "${product.discountPercentage ?? 0}% OFF",
              originalPrice: "${product.beforeDiscountPrice ?? 0}",
            );
          },
        );
      },
    );
  }
}
