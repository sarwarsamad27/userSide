import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/widgets/customBgContainer.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Offers",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.black,
          ),
        ),
      ),

      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🛍️ Header
                Text(
                  "Exclusive Deals for You 🎁",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Grab the best discounts and cashback offers before they expire!",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                ),
                SizedBox(height: 20.h),

                /// 💥 Offer Cards
                offerCard(
                  emoji: "🎉",
                  title: "Get 30% OFF on your next order",
                  subtitle: "Use code: SAVE30 at checkout",
                  color: Colors.orangeAccent,
                ),
                SizedBox(height: 12.h),

                offerCard(
                  emoji: "💰",
                  title: "Flat ₹100 Cashback on orders above ₹999",
                  subtitle: "Valid for prepaid payments only",
                  color: Colors.greenAccent,
                ),
                SizedBox(height: 12.h),

                offerCard(
                  emoji: "🚚",
                  title: "Free Delivery on your first 3 orders",
                  subtitle: "No minimum cart value required",
                  color: Colors.blueAccent,
                ),
                SizedBox(height: 12.h),

                offerCard(
                  emoji: "🎁",
                  title: "Refer & Earn ₹200",
                  subtitle: "Invite friends and get rewards instantly",
                  color: Colors.pinkAccent,
                ),
                SizedBox(height: 12.h),

                offerCard(
                  emoji: "🔥",
                  title: "Mega Sale: Up to 50% OFF on top brands",
                  subtitle: "Limited-time offer",
                  color: Colors.redAccent,
                ),
                SizedBox(height: 20.h),

                /// ⚠️ Note Section
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.yellowAccent),
                  ),
                  child: Text(
                    "⚠️ Offers are subject to change without prior notice. "
                    "Please check the terms and conditions before applying any promo code.",
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reusable Offer Card Widget
  Widget offerCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
