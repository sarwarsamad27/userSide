import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:user_side/resources/appColor.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onFilterTap;
  final Function(String)? onChanged;

  // Premium usability (optional; old usages won't break)
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autofocus;

  const CustomSearchBar({
    super.key,
    this.hintText = "Search...",
    this.onFilterTap,
    this.onChanged,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withOpacity(0.92)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            height: 36.h,
            width: 36.h,
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColor.primaryColor.withOpacity(0.12),
              ),
            ),
            child: Icon(
              LucideIcons.search,
              color: AppColor.primaryColor,
              size: 20.sp,
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                autofocus: autofocus,
                onChanged: onChanged,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimaryColor,
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),

          if (onFilterTap != null) ...[
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                height: 40.h,
                width: 44.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.primaryColor.withOpacity(0.95),
                      AppColor.primaryColor.withOpacity(0.70),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.slidersHorizontal,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
