import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
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

        return Container(
          margin: EdgeInsets.fromLTRB(0.w, 18.h, 0.w, 6.h),
          padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 18.h),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.primaryColor.withOpacity(0.08),
                AppColor.whiteColor,
              ],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: AppColor.primaryColor.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            widget.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
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
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "See All",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13.sp,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              SizedBox(
                height: 290.h,
                child: loading
                    ? Center(child: Utils.shoppingLoadingLottie(size: 60))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: products!.length,
                        separatorBuilder: (_, __) => SizedBox(width: 14.w),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final imageUrl =
                              (product.images != null &&
                                  product.images!.isNotEmpty)
                              ? product.images!.first
                              : '';

                          return Container(
                            width: 182.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
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
