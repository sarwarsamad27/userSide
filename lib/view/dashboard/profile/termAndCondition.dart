import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});

  static const _sections = [
    _TermsSection(
      icon: Icons.shopping_bag_rounded,
      title: 'Orders & Payments',
      items: [
        'All sales made through this app are final and non-refundable unless eligible for exchange.',
        'Discounts, promo codes, and offers cannot be combined unless specified.',
      ],
    ),
    _TermsSection(
      icon: Icons.local_shipping_rounded,
      title: 'Delivery',
      items: [
        'Delivery times may vary based on your location and product availability.',
        'Ensure that your shipping details are accurate before confirming an order.',
        'Shookoo is not responsible for delays caused by third-party logistics providers.',
      ],
    ),
    _TermsSection(
      icon: Icons.price_change_rounded,
      title: 'Pricing & Offers',
      items: [
        'Prices, offers, and availability are subject to change without prior notice.',
        'By continuing to use this app, you agree to comply with all the terms mentioned herein.',
      ],
    ),
    _TermsSection(
      icon: Icons.security_rounded,
      title: 'Account & Security',
      items: [
        'We reserve the right to suspend accounts involved in fraudulent or suspicious activity.',
        'Your data will be handled as per our Privacy Policy and local regulations.',
      ],
    ),
    _TermsSection(
      icon: Icons.help_rounded,
      title: 'Support',
      items: [
        'For further details, please contact our Help Center or Customer Support.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          'Terms & Conditions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Scrollable content ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intro card
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColor.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColor.primaryColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Please read the following terms and conditions '
                            'carefully before using our services.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Sections
                  ...List.generate(_sections.length, (i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _TermsCard(section: _sections[i], index: i + 1),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Fixed bottom button ──────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                label: Text(
                  'I Understand & Agree',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsSection {
  final IconData icon;
  final String title;
  final List<String> items;
  const _TermsSection({
    required this.icon,
    required this.title,
    required this.items,
  });
}

class _TermsCard extends StatelessWidget {
  final _TermsSection section;
  final int index;
  const _TermsCard({required this.section, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    section.icon,
                    color: AppColor.primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  section.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E2D),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Container(height: 1, color: Colors.grey.shade100),
            SizedBox(height: 12.h),

            // Items
            ...List.generate(section.items.length, (i) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i < section.items.length - 1 ? 10.h : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5.h),
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        section.items[i],
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
