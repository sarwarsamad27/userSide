import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/profile/profileScreen.dart';

class PremiumOfferCard extends StatelessWidget {
  final OfferCardData data;
  final bool isActive;

  const PremiumOfferCard({required this.data, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.88),
            Colors.black.withOpacity(0.50),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isActive ? AppColor.primaryColor : Colors.black)
                .withOpacity(0.18),
            blurRadius: isActive ? 26 : 16,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.07), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 11.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.20),
                          ),
                        ),
                        child: Text(
                          data.badge,
                          style: TextStyle(
                            fontSize: 11.sp,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "${data.emoji}  ${data.title}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        data.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  height: 56.h,
                  width: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.10),
                    border: Border.all(color: Colors.white.withOpacity(0.20)),
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 28.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

