import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomProductTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String? price;
  final String? discountText; // optional
  final String? saveText; // optional
  final VoidCallback? onTap;

  const CustomProductTile({
    Key? key,
    required this.imageUrl,
    required this.name,
    this.onTap,
    this.price,
    this.discountText,
    this.saveText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  imageUrl,
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.cover,
                ),
              ),

              /// Discount Badge (optional)
              if (discountText != null)
                Positioned(
                  top: 5.h,
                  left: 5.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      discountText!,
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              /// Save Badge (optional)
              if (saveText != null)
                Positioned(
                  top: 5.h,
                  right: 5.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      saveText!,
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          FittedBox(
            child: Text(
              name,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
            ),
          ),
          FittedBox(
            child: Text(
              price ?? '',
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurpleAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
