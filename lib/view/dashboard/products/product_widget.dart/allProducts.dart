import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/models/ProductAndCategoryModel/getAllProduct_model.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/categoryPreviewRow.dart';
import 'package:user_side/viewModel/provider/productProvider/getAllProduct_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularCategory_provider.dart';
import 'package:user_side/widgets/productCard.dart';

/// After every chunk of this many products, a horizontal category carousel
/// is inserted so the feed keeps surfacing different categories on scroll.
const int _kCategoryInsertEvery = 12;

class AllProducts extends StatelessWidget {
  const AllProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 14.h),
      sliver: Consumer2<GetAllProductProvider, PopularCategoryProvider>(
        builder: (context, provider, categoryProvider, child) {
          final products = provider.filteredProducts;

          if (provider.loading && products.isEmpty) {
            return SliverToBoxAdapter(
              child: Utils.shoppingLoadingLottie(size: 80),
            );
          }

          final categories = categoryProvider.allCategories
              .where((c) => (c.categoryName ?? '').isNotEmpty)
              .toList();

          final chunkCount = products.isEmpty
              ? 0
              : (products.length / _kCategoryInsertEvery).ceil();

          final slivers = <Widget>[];
          int categoryRotationIndex = 0;

          for (int chunk = 0; chunk < chunkCount; chunk++) {
            final start = chunk * _kCategoryInsertEvery;
            final end = ((chunk + 1) * _kCategoryInsertEvery).clamp(
              0,
              products.length,
            );
            final chunkProducts = products.sublist(start, end);

            slivers.add(_buildGrid(context, chunkProducts));

            final isFullChunk = chunkProducts.length == _kCategoryInsertEvery;
            if (isFullChunk && categories.isNotEmpty) {
              final category =
                  categories[categoryRotationIndex % categories.length];
              categoryRotationIndex++;
              slivers.add(
                SliverToBoxAdapter(
                  child: CategoryPreviewRow(
                    category: category.categoryName ?? '',
                  ),
                ),
              );
            }
          }

          if (provider.loadMore) {
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
              ),
            );
          }

          if (!provider.hasMore && products.isNotEmpty) {
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: Text(
                      "No more products",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            );
          }

          return SliverMainAxisGroup(slivers: slivers);
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Products> chunkProducts) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index >= chunkProducts.length) {
          return const SizedBox();
        }

        final product = chunkProducts[index];

        final imageUrl =
            (product.images != null && product.images!.isNotEmpty)
            ? product.images!.first
            : ''; // empty instead of placeholder

        return ProductCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      profileId: product.profileId ?? "",
                      categoryId: product.categoryId ?? "",
                      productId: product.productId ?? "",
                    ),
                  ),
                );
              },
              imageUrl: imageUrl.isNotEmpty
                  ? (imageUrl.startsWith('http')
                        ? Global.getImageUrl(imageUrl)
                        : imageUrl)
                  : '', // pass empty to show icon in ProductCard
              price: "${product.afterDiscountPrice ?? 0}",
              name: product.name ?? "",
              description: product.description ?? "",
              saveText: "${product.discountPercentage ?? 0}% OFF",

              averageRating: product.averageRating ?? 0.0,
              originalPrice: "${product.beforeDiscountPrice ?? 0}",
              quantity: product.quantity,
            )
            .animate()
            .fadeIn(delay: (index * 40).ms)
            .slideY(begin: 0.1, curve: Curves.easeOutQuad);
      }, childCount: chunkProducts.length),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 4.w,
        mainAxisExtent: 265.h,
      ),
    );
  }
}
