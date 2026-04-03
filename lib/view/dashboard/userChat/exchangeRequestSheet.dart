// view/dashboard/userChat/exchangeRequestSheet.dart
// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:user_side/models/order/myOrderModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';

class ExchangeRequestSheet extends StatefulWidget {
  final Orders order;
  final List<Product> products;

  const ExchangeRequestSheet({
    super.key,
    required this.order,
    required this.products,
  });

  @override
  State<ExchangeRequestSheet> createState() => _ExchangeRequestSheetState();
}

class _ExchangeRequestSheetState extends State<ExchangeRequestSheet> {
  final TextEditingController _reason = TextEditingController();
  Product? _selectedProduct;
  String _reasonCategory = "buyer_preference"; // default
  List<XFile> _images = [];

  final ImagePicker _picker = ImagePicker();

  // Reason categories
  static const _categories = [
    _Category(
      "seller_fault",
      "Wrong Item Received",
      "Seller sent wrong product",
      Icons.error_outline,
      Colors.red,
    ),
    _Category(
      "defective",
      "Defective / Damaged",
      "Product is damaged or not working",
      Icons.broken_image_outlined,
      Colors.orange,
    ),
    _Category(
      "size_color",
      "Wrong Size / Color",
      "Size or color doesn't match",
      Icons.straighten_outlined,
      Colors.blue,
    ),
    _Category(
      "buyer_preference",
      "Changed My Mind",
      "I want a different product",
      Icons.swap_horiz,
      Colors.grey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.products.isNotEmpty) _selectedProduct = widget.products.first;
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) {
      if (mounted) PremiumToast.error(context, "Maximum 5 images allowed");
      return;
    }
    final files = await _picker.pickMultiImage(imageQuality: 75);
    if (files.isEmpty) return;
    final remaining = 5 - _images.length;
    setState(() {
      _images = [..._images, ...files.take(remaining)];
    });
  }

  Future<List<String>> _imagesToBase64() async {
    final List<String> result = [];
    for (final x in _images) {
      final bytes = await File(x.path).readAsBytes();
      result.add("data:image/jpg;base64,${base64Encode(bytes)}");
    }
    return result;
  }

  Future<void> _submit() async {
    if (_selectedProduct == null) {
      PremiumToast.error(context, "Product not selected");
      return;
    }
    if (_reason.text.trim().isEmpty) {
      PremiumToast.error(context, "Please describe the reason");
      return;
    }

    final provider = context.read<ExchangeProvider>();
    final buyerId = await LocalStorage.getUserId() ?? "";
    if (buyerId.isEmpty) {
      PremiumToast.error(context, "User ID not found");
      return;
    }

    final imagesB64 = await _imagesToBase64();

    final ok = await provider.createRequest(
      buyerId: buyerId,
      orderId: widget.order.orderId ?? "",
      id: widget.order.id ?? "", // ✅ Sent ObjectId separately
      productId: _selectedProduct!.productId ?? "",
      reason: _reason.text.trim(),
      reasonCategory: _reasonCategory,
      images: imagesB64,
    );

    if (!mounted) return;

    if (ok) {
      PremiumToast.success(
        context,
        provider.createModel?.message ?? "Exchange request submitted",
      );
      Navigator.pop(context);
    } else {
      PremiumToast.error(
        context,
        provider.createModel?.message ?? "Failed to submit request",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final creating = context.select<ExchangeProvider, bool>((p) => p.creating);

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Exchange Request",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Tell us why you want to exchange",
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
            SizedBox(height: 16.h),

            // Product selector
            if (widget.products.length > 1)
              DropdownButtonFormField<Product>(
                value: _selectedProduct,
                items: widget.products.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p.name ?? "N/A"),
                  );
                }).toList(),
                onChanged: creating
                    ? null
                    : (v) => setState(() => _selectedProduct = v),
                decoration: InputDecoration(
                  labelText: "Select Product",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),

            SizedBox(height: 14.h),

            // Reason category chips
            Text(
              "Reason Category",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10.h),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 2.8,
              children: _categories.map((cat) {
                final selected = _reasonCategory == cat.value;
                return GestureDetector(
                  onTap: creating
                      ? null
                      : () => setState(() => _reasonCategory = cat.value),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? cat.color.withOpacity(0.12)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: selected ? cat.color : Colors.grey[300]!,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat.icon,
                          size: 16.sp,
                          color: selected ? cat.color : Colors.grey,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: selected ? cat.color : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Courier cost hint
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _isBuyerFault ? Colors.orange[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: _isBuyerFault
                      ? Colors.orange[200]!
                      : Colors.green[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 16.sp,
                    color: _isBuyerFault
                        ? Colors.orange[700]
                        : Colors.green[700],
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _isBuyerFault
                          ? "Return courier cost will be your responsibility"
                          : "Seller will cover all courier costs",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _isBuyerFault
                            ? Colors.orange[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // Reason text
            TextField(
              controller: _reason,
              maxLines: 3,
              enabled: !creating,
              decoration: InputDecoration(
                labelText: "Describe the issue *",
                hintText: "Provide details about what's wrong...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AppColor.primaryColor),
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // Images
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Product Photos (${_images.length}/5)",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: creating ? null : _pickImages,
                  icon: Icon(Icons.add_photo_alternate, size: 18.sp),
                  label: const Text("Add"),
                ),
              ],
            ),
            if (_images.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.h,
                  crossAxisSpacing: 8.w,
                ),
                itemBuilder: (_, i) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        File(_images[i].path),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: creating
                            ? null
                            : () => setState(() => _images.removeAt(i)),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: creating ? null : _submit,
                child: creating
                    ? Utils.loadingLottie(size: 24)
                    : Text(
                        "Submit Exchange Request",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isBuyerFault =>
      _reasonCategory == "buyer_preference" || _reasonCategory == "size_color";
}

class _Category {
  final String value;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _Category(this.value, this.label, this.subtitle, this.icon, this.color);
}
