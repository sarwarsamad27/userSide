import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/widgets/customContainer.dart';

Widget optionTile(
  BuildContext context,
  IconData icon,
  String title,
  Color color,
  Widget screen,
) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    },
    child: CustomAppContainer(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      width: 170.w,
      height: 60.h,
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}
