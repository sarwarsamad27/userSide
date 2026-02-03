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
    // Facebook-style: soft grey pill, subtle border, minimal shadow, left search icon
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            autofocus: autofocus,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimaryColor,
              height: 3.2,
            ),
            decoration: InputDecoration(
              
              hintText: hintText,
              hintStyle: TextStyle(
                color: const Color(0xFF65676B),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 1.h),
            ),
            textInputAction: TextInputAction.search,
          ),
        ),

        if (onFilterTap != null) ...[
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              height: 34.h,
              width: 34.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Icon(
                LucideIcons.slidersHorizontal,
                color: const Color(0xFF65676B),
                size: 18.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
