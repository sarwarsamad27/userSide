import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfile/companyProfileScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productImage.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/review/review.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/widgets/premiumSurface.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/widgets/productShareSheet.dart';
import 'package:user_side/view/dashboard/userChat/userChatScreen.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/productDetailUI_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/productShare_provider.dart';

class ProductMainCard extends StatelessWidget {
  final GetSingleProductModel data;

  const ProductMainCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;
    final product = data.product!;
    log(data.profileImage.toString());

    final before = product.beforeDiscountPrice ?? 0;
    final after = product.afterDiscountPrice ?? 0;

    int discountPercent = 0;
    if (before > 0 && after > 0 && before > after) {
      discountPercent = (((before - after) / before) * 100).round();
    }

    String getValidImageUrl(String? url) {
      if (url == null) return '';
      if (url.startsWith('http')) return url;
      return Global.imageUrl + url;
    }

    return Column(
      children: [
        Consumer<ProductDetailUiProvider>(
          builder: (_, ui, __) {
            return ProductImage(
              imageUrls: product.images ?? [],
              onImageChange: (index) => ui.onImageChange(index),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          child: PremiumSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),

                // ───────── Brand/Company row ─────────
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyProfileScreen(
                          companyName: data.profileName ?? "",
                          logoUrl: (data.profileImage ?? ""),
                          profileId: data.product!.profileId ?? "",
                          categoryId: data.product!.categoryId ?? "",
                          description: data.profileDescription ?? "",
                          phoneNumber: data.profilephoneNumber ?? "",
                          email: data.profileEmail ?? "",
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColor.primaryColor.withOpacity(0.9),
                              AppColor.primaryColor.withOpacity(0.35),
                            ],
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: CircleAvatar(
                            radius: 22.r,
                            backgroundColor: const Color(0xFFF3F4F6),
                            backgroundImage: data.profileImage != null
                                ? NetworkImage(
                                    getValidImageUrl(data.profileImage),
                                  )
                                : null,
                            child: data.profileImage == null
                                ? Icon(
                                    Icons.storefront_outlined,
                                    color: const Color(0xFF6B7280),
                                    size: 20.sp,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.profileName ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "View brand profile",
                              style: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 14.sp,
                              color: AppColor.primaryColor,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "Brand",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),
                const DividerLine(),
                SizedBox(height: 16.h),

                // ───────── Average rating ─────────
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18.sp),
                    SizedBox(width: 4.w),
                    Text(
                      (data.averageRating ?? 0).toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "(${data.reviews?.length ?? 0} reviews)",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // ───────── Name + Chat + Share + Stock ─────────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name ?? "",
                        style: TextStyle(
                          color: const Color(0xFF111827),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 22.sp,
                        color: const Color(0xFF111827),
                      ),
                      onPressed: () async {
                        if (!isLoggedIn) {
                          AppToast.show("Login your account to chat");
                        } else {
                          final sellerId = product.profileId ?? '';
                          if (sellerId.isEmpty) return;

                          final buyerId = await LocalStorage.getUserId();
                          if (buyerId == null || buyerId.isEmpty) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please login first'),
                                ),
                              );
                            }
                            return;
                          }

                          final threadId = 'buyer_${buyerId}_seller_$sellerId';

                          if (context.mounted) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ProductShareSheet(
                                productImage: product.images?.isNotEmpty == true
                                    ? product.images!.first
                                    : '',
                                productName: product.name ?? '',
                                productPrice:
                                    '${product.afterDiscountPrice ?? 0}',
                                productDescription: product.description,
                                brandName: data.profileName ?? '',
                                sellerId: sellerId,
                                // ✅ UPDATED: Accept structured data
                                onSend: (sellerId, productData, message) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserChatScreen(
                                        threadId: threadId,
                                        toType: 'seller',
                                        toId: sellerId,
                                        title: data.profileName ?? 'Chat',
                                        sellerImage: data.profileImage,
                                        // ✅ Pass as Map instead of text
                                        initialProductData: productData,
                                        initialMessage: message,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share_outlined,
                        size: 22.sp,
                        color: const Color(0xFF111827),
                      ),
                      onPressed: () async {
                        final shareProvider = context
                            .read<ProductShareProvider>();

                        final link = await shareProvider.fetchShareLink(
                          productId: product.sId ?? '',
                          profileId: product.profileId ?? '',
                        );

                        if (link == null || link.isEmpty) return;

                        final name = product.name ?? '';
                        final desc = product.description ?? '';
                        final price = product.afterDiscountPrice ?? 0;
                        final brand = data.profileName ?? '';

                        final shareText =
                            '''
$name
$desc

Brand: $brand
Price: Rs: $price

$link
''';

                        await Share.share(shareText);
                      },
                    ),

                    // Stock badge
                    Builder(
                      builder: (_) {
                        final String stockText = (product.stock ?? "In Stock")
                            .trim();
                        final bool isOutOfStock =
                            stockText.toLowerCase() == "out of stock";
                        final Color bgColor = isOutOfStock
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFFFEDD5);
                        final Color borderColor = isOutOfStock
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFFDBA74);
                        final Color textColor = isOutOfStock
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFFC2410C);

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            stockText.isEmpty ? "In Stock" : stockText,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // ───────── Price + discount badge ─────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Rs: ${product.afterDiscountPrice ?? 0}",
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    if ((product.beforeDiscountPrice ?? 0) > 0)
                      Text(
                        "Rs: ${product.beforeDiscountPrice ?? 0}",
                        style: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                        ),
                      ),
                    const Spacer(),
                    if (discountPercent > 0)
                      PillBadge(
                        text: "$discountPercent% OFF",
                        background: const Color(0xFF16A34A),
                        border: const Color(0xFFDCFCE7),
                      ),
                  ],
                ),

                SizedBox(height: 16.h),

                const SectionHeader(title: "Description"),
                SizedBox(height: 8.h),
                Text(
                  product.description ?? "",
                  style: TextStyle(
                    color: const Color(0xFF4B5563),
                    height: 1.55,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 18.h),
                const DividerLine(),
                SizedBox(height: 16.h),

                if (product.color != null && product.color!.isNotEmpty) ...[
                  const SectionHeader(title: "Select Color"),
                  SizedBox(height: 10.h),
                  Consumer<ProductDetailUiProvider>(
                    builder: (_, ui, __) {
                      return Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: product.color!.map((color) {
                          final selected = ui.selectedColors.contains(color);
                          return ChoicePill(
                            text: color,
                            selected: selected,
                            onTap: () => ui.toggleColor(color),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 18.h),
                ],

                if (product.size != null && product.size!.isNotEmpty) ...[
                  const SectionHeader(title: "Select Size"),
                  SizedBox(height: 10.h),
                  Consumer<ProductDetailUiProvider>(
                    builder: (_, ui, __) {
                      return Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: product.size!.map((size) {
                          final selected = ui.selectedSizes.contains(size);
                          return ChoicePill(
                            text: size,
                            selected: selected,
                            onTap: () => ui.toggleSize(size),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 18.h),
                ],

                Consumer<GetSingleProductProvider>(
                  builder: (_, provider, __) {
                    return Review(
                      productId: product.sId ?? '',
                      reviews: provider.productData?.reviews ?? [],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
