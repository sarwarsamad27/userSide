import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllProductCategoryWise_provider.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/widgets/productCard.dart';

class ProductBelowCategory extends StatefulWidget {
  final String profileId;
  final String categoryId;

  const ProductBelowCategory({
    Key? key,
    required this.profileId,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<ProductBelowCategory> createState() => _ProductBelowCategoryState();
}

class _ProductBelowCategoryState extends State<ProductBelowCategory> {
  @override
  void initState() {
    super.initState();
    Provider.of<GetAllProductCategoryWiseProvider>(
      context,
      listen: false,
    ).fetchProducts(widget.profileId, widget.categoryId);
  }

  /// ⚠️ FIX: Jab categoryId change ho → dobara API call
  @override
  void didUpdateWidget(covariant ProductBelowCategory oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.categoryId != widget.categoryId) {
      Provider.of<GetAllProductCategoryWiseProvider>(
        context,
        listen: false,
      ).fetchProducts(widget.profileId, widget.categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetAllProductCategoryWiseProvider>(context);
    final media = MediaQuery.of(context).size;

    return Expanded(
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.data == null ||
                provider.data!.products == null ||
                provider.data!.products!.isEmpty
          ? const Center(child: Text("No Products Found"))
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: GridView.builder(
                itemCount: provider.data!.products!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: media.width < 600 ? 2 : 4,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: media.width < 600 ? 0.72 : 0.8,
                ),
                itemBuilder: (context, index) {
                  final p = provider.data!.products![index];

                  return InkWell(
                    child: ProductCard(
                      name: p.name ?? "",
                      price: p.afterDiscountPrice?.toString() ?? "0",
                      imageUrl: p.images?.isNotEmpty == true
                          ? p.images!.first
                          : "",
                      description: p.description ?? "",
                      originalPrice: p.beforeDiscountPrice?.toString() ?? "0",
                      discountText: "${p.discountPercentage ?? 0}% OFF",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              profileId: p.profileId ?? '',
                               categoryId: p.categoryId ?? '',
                                productId: p.sId ?? '',
                             
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
