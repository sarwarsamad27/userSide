import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/widgets/customBgContainer.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final terms = [
      "All sales made through this app are final and non-refundable.",
      "Discounts, promo codes, and offers cannot be combined unless specified.",
      "Delivery times may vary based on your location and product availability.",
      "Ensure that your shipping details are accurate before confirming an order.",
      "Nichee is not responsible for delays caused by third-party logistics providers.",
      "Prices, offers, and availability are subject to change without prior notice.",
      "By continuing to use this app, you agree to comply with all the terms mentioned herein.",
      "We reserve the right to suspend accounts involved in fraudulent or suspicious activity.",
      "Your data will be handled as per our Privacy Policy and local regulations.",
      "For further details, please contact our Help Center or Customer Support.",
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Terms & Conditions",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.black,
          ),
        ),
      ),

      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 📜 Intro Text
                  Text(
                    "Please read the following terms and conditions carefully before using our services.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  /// 🧾 Terms List
                  ...List.generate(
                    terms.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${index + 1}. ",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              terms[index],
                              style: TextStyle(
                                fontSize: 15.sp,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 25.h),

                  /// ✅ Accept Button
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      label: Text(
                        "I Understand",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
