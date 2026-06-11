import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/viewModel/provider/productProvider/getAllProduct_provider.dart';
import 'package:user_side/widgets/productCard.dart';

class DiscountedProductsScreen extends StatefulWidget {
  final int minDiscount;
  const DiscountedProductsScreen({super.key, this.minDiscount = 50});

  @override
  State<DiscountedProductsScreen> createState() =>
      _DiscountedProductsScreenState();
}

class _DiscountedProductsScreenState extends State<DiscountedProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GetAllProductProvider>();
      if (!provider.isFetchedOnce) {
        provider.fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Up to ${widget.minDiscount}% OFF',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<GetAllProductProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.allProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final discounted = provider.allProducts
              .where((p) => (p.discountPercentage ?? 0) >= widget.minDiscount)
              .toList();

          if (discounted.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64.sp,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No ${widget.minDiscount}% off deals right now',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Header banner
          return RefreshIndicator(
            color: AppColor.primaryColor,
            onRefresh: () async {
              provider.isFetchedOnce = false;
              await provider.fetchProducts();
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(16.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColor.appimagecolor, AppColor.primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [ 
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mega Sale 🔥',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${discounted.length} products at ${widget.minDiscount}%+ off',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.flash_on_rounded,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final p = discounted[index];
                      final imageUrl =
                          (p.images != null && p.images!.isNotEmpty)
                          ? p.images!.first
                          : '';
                      return ProductCard(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  profileId: p.profileId ?? '',
                                  categoryId: p.categoryId ?? '',
                                  productId: p.productId ?? '',
                                ),
                              ),
                            ),
                            imageUrl: imageUrl.isNotEmpty
                                ? (imageUrl.startsWith('http')
                                      ? Global.getImageUrl(imageUrl)
                                      : imageUrl)
                                : '',
                            price: '${p.afterDiscountPrice ?? 0}',
                            name: p.name ?? '',
                            description: p.description ?? '',
                            saveText: '${p.discountPercentage ?? 0}% OFF',
                            originalPrice: '${p.beforeDiscountPrice ?? 0}',
                            averageRating: p.averageRating ?? 0.0,
                            quantity: p.quantity,
                          )
                          .animate()
                          .fadeIn(delay: (index * 40).ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutQuad);
                    }, childCount: discounted.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 4.w,
                      mainAxisExtent: 265.h,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
              ],
            ),
          );
        },
      ),
    );
  }
}
