import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/models/chatModel/chatModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';

/// Bottom sheet for sharing product in chat (Daraz-style)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';

/// Bottom sheet for sharing product in chat
class ProductShareSheet extends StatefulWidget {
  final String productImage;
  final String productName;
  final String productPrice;
  final String? productDescription;
  final String brandName;
  final String sellerId;
  
  // ✅ NEW: Structured product data callback
  final Function(
    String sellerId,
    Map<String, dynamic> productData, // ✅ Changed to Map
    String? message,
  ) onSend;

  const ProductShareSheet({
    super.key,
    required this.productImage,
    required this.productName,
    required this.productPrice,
    required this.productDescription,
    required this.brandName,
    required this.sellerId,
    required this.onSend,
  });

  @override
  State<ProductShareSheet> createState() => _ProductShareSheetState();
}

class _ProductShareSheetState extends State<ProductShareSheet> {
  final TextEditingController _messageController = TextEditingController();

  String _getValidImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return Global.imageUrl + url;
  }

  void _handleSend() {
    // ✅ Create structured product data (NO TEXT PARSING)
    final productData = {
      'productName': widget.productName,
      'productPrice': widget.productPrice,
      'productDescription': widget.productDescription ?? '',
      'productImage': widget.productImage,
      'brandName': widget.brandName,
      'sellerId': widget.sellerId,
    };

    final message = _messageController.text.trim();

    // ✅ Close sheet FIRST
    Navigator.pop(context);
    
    // ✅ Then call callback with structured data
    widget.onSend(
      widget.sellerId,
      productData, // ✅ Pass Map instead of text
      message.isNotEmpty ? message : null,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          SizedBox(height: 16.h),

          // Title
          Text(
            "Share Product",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),

          SizedBox(height: 16.h),

          // Product Card Preview
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      bottomLeft: Radius.circular(12.r),
                    ),
                    child: Image.network(
                      _getValidImageUrl(widget.productImage),
                      width: 100.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100.w,
                        height: 100.h,
                        color: const Color(0xFFF3F4F6),
                        child: Icon(
                          Icons.image_outlined,
                          size: 40.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),

                  // Product Details
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            widget.brandName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "Rs: ${widget.productPrice}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Message Input + Send Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: "Add a message (optional)",
                        hintStyle: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}



class ProductCardWidget extends StatelessWidget {
  final ProductCard productCard;
  final bool isMe;
  
  const ProductCardWidget({
    super.key,
    required this.productCard,
    required this.isMe,
  });



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 8.h,
        left: isMe ? 60.w : 0,
        right: isMe ? 0 : 60.w,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 18.sp,
                    color: AppColor.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Product Inquiry",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Product Content
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    productCard.productName ?? 'Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Brand Name
                  Text(
                    productCard.brandName ?? 'Brand',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),

                  if (productCard.productDescription != null && 
                      productCard.productDescription!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      productCard.productDescription!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],

                  SizedBox(height: 12.h),

                  // Price Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColor.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      "Rs: ${productCard.productPrice ?? '0'}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}