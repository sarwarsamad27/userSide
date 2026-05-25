import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/products/discounted_products_screen.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = [
      _OfferData(
        icon: Icons.workspace_premium_rounded,
        badge: 'LOYALTY',
        title: 'Earn Rs 100 on Every Big Order',
        subtitle: 'Automatic cashback on every order above Rs 5,000',
        color: const Color(0xFF8B5CF6),
      ),
      _OfferData(
        icon: Icons.account_balance_wallet_rounded,
        badge: 'CASHBACK',
        title: 'Rs 100 Cashback on orders above Rs 5,000',
        subtitle: 'Delivered to your wallet automatically — no code needed',
        color: const Color(0xFF10B981),
      ),
      _OfferData(
        icon: Icons.local_shipping_rounded,
        badge: 'FREE',
        title: 'Spend 10,000 and get free shipping',
        subtitle: 'No minimum cart value required',
        color: const Color(0xFF3B82F6),
      ),
      _OfferData(
        icon: Icons.trending_up_rounded,
        badge: 'TRENDING',
        title: 'New Drops Every Week',
        subtitle: 'Fresh products from top sellers — be first to grab them',
        color: const Color(0xFFDF762E),
      ),
      _OfferData(
        icon: Icons.flash_on_rounded,
        badge: 'SALE',
        title: 'Mega Sale: Up to 50% OFF',
        subtitle: 'On top brands — limited time only',
        color: const Color(0xFFEF4444),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DiscountedProductsScreen(minDiscount: 50),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
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
          'Offers & Deals',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Save More,\nShop Smarter',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Cashback, deals & more — all in one place',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white.withValues(alpha: 0.85),
                    size: 54.sp,
                  ),
                ],
              ),
            ),

            // ── Offers List ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Offers',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E2D),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...offers.map(
                    (o) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _OfferCard(offer: o),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // ── Disclaimer ─────────────────────────────────────────
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.amber.shade700,
                          size: 18.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Offers are subject to change without prior notice. '
                            'Check terms before applying any promo code.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.amber.shade800,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferData {
  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  const _OfferData({
    required this.icon,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });
}

class _OfferCard extends StatelessWidget {
  final _OfferData offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: offer.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Row(
            children: [
              // Colored left accent
              Container(width: 5.w, height: 82.h, color: offer.color),
              SizedBox(width: 14.w),
              // Icon
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: offer.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(offer.icon, color: offer.color, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: offer.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              offer.badge,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: offer.color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (offer.onTap != null) ...[
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(width: 14.w),
                          ],
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        offer.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E1E2D),
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        offer.subtitle,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (offer.onTap == null) SizedBox(width: 14.w),
            ],
          ),
        ),
      ),
    );
  }
}
