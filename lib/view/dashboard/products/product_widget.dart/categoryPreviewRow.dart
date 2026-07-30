import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/categoryProductsScreen.dart';
import 'package:user_side/viewModel/provider/productProvider/categoryPreview_provider.dart';
import 'package:user_side/widgets/productCard.dart';

/// Horizontally-scrolling row of products from a single category, inserted
/// between chunks of the main vertical product grid so the feed keeps
/// surfacing different categories as the user scrolls.
class CategoryPreviewRow extends StatefulWidget {
  final String category;

  const CategoryPreviewRow({super.key, required this.category});

  @override
  State<CategoryPreviewRow> createState() => _CategoryPreviewRowState();
}

class _CategoryPreviewRowState extends State<CategoryPreviewRow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CategoryPreviewProvider>().fetchPreview(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryPreviewProvider>(
      builder: (context, provider, child) {
        final loading = provider.isLoading(widget.category);
        final products = provider.previewFor(widget.category);

        if (!loading && (products == null || products.isEmpty)) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(top: 18.h, bottom: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (!loading && products != null && products.isNotEmpty)
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CategoryProductsScreen(category: widget.category),
                          ),
                        ),
                        child: Text(
                          "See All",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 250.h,
                child: loading
                    ? Center(child: Utils.shoppingLoadingLottie(size: 60))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        itemCount: products!.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final imageUrl =
                              (product.images != null &&
                                  product.images!.isNotEmpty)
                              ? product.images!.first
                              : '';

                          return SizedBox(
                            width: 160.w,
                            child: ProductCard(
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
                              imageUrl: imageUrl.isNotEmpty
                                  ? (imageUrl.startsWith('http')
                                        ? Global.getImageUrl(imageUrl)
                                        : imageUrl)
                                  : '',
                              price: "${product.afterDiscountPrice ?? 0}",
                              name: product.name ?? "",
                              description: product.description ?? "",
                              discountText:
                                  "${product.discountPercentage ?? 0}% OFF",
                              averageRating: product.averageRating ?? 0.0,
                              originalPrice:
                                  "${product.beforeDiscountPrice ?? 0}",
                              quantity: product.quantity,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
