// view/dashboard/userChat/refundRequestSheet.dart
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
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';

class RefundRequestSheet extends StatefulWidget {
  final Orders order;
  final List<Product> products;

  const RefundRequestSheet({
    super.key,
    required this.order,
    required this.products,
  });

  @override
  State<RefundRequestSheet> createState() => _RefundRequestSheetState();
}

class _RefundRequestSheetState extends State<RefundRequestSheet> {
  final TextEditingController _reason = TextEditingController();
  Product? _selectedProduct;
  String _reasonCategory = "buyer_preference";
  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  static const _categories = [
    _Category("seller_fault", "Wrong Item", Icons.error_outline, Colors.red),
    _Category(
      "defective",
      "Defective",
      Icons.broken_image_outlined,
      Colors.orange,
    ),
    _Category(
      "size_issue",
      "Size Issue",
      Icons.straighten_outlined,
      Colors.blue,
    ),
    _Category(
      "wrong_item",
      "Different Product",
      Icons.inventory_2_outlined,
      Colors.purple,
    ),
    _Category(
      "buyer_preference",
      "Changed Mind",
      Icons.sentiment_neutral,
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
      PremiumToast.error(context, "Max 5 images");
      return;
    }
    final files = await _picker.pickMultiImage(imageQuality: 70);
    if (files.isEmpty) return;
    setState(() {
      _images = [..._images, ...files].take(5).toList();
    });
  }

  Future<void> _submit() async {
    if (_selectedProduct == null)
      return PremiumToast.error(context, "Select product");
    if (_reason.text.trim().isEmpty)
      return PremiumToast.error(context, "Provide reason");

    final provider = context.read<ExchangeProvider>();
    final userId = await LocalStorage.getUserId() ?? "";

    final List<String> b64Images = [];
    for (var img in _images) {
      final bytes = await File(img.path).readAsBytes();
      b64Images.add("data:image/jpg;base64,${base64Encode(bytes)}");
    }

    final ok = await provider.createRefund(
      buyerId: userId,
      orderId: widget.order.orderId ?? "",
      id: widget.order.id ?? "",
      productId: _selectedProduct!.productId ?? "",
      reason: _reason.text.trim(),
      reasonCategory: _reasonCategory,
      images: b64Images,
    );

    if (!mounted) return;
    if (ok) {
      PremiumToast.success(context, "Refund request sent");
      Navigator.pop(context);
    } else {
      PremiumToast.error(
        context,
        provider.errorMessage ?? "Failed to send request",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final creating = context.select<ExchangeProvider, bool>((p) => p.creating);

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 10.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Request Refund",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              "Wallet will be credited after approval",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 15.h),

            if (widget.products.length > 1)
              DropdownButtonFormField<Product>(
                value: _selectedProduct,
                items: widget.products
                    .map(
                      (p) =>
                          DropdownMenuItem(value: p, child: Text(p.name ?? "")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedProduct = v),
                decoration: InputDecoration(
                  labelText: "Product",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),

            SizedBox(height: 15.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Reason Category",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _categories.map((c) {
                final sel = _reasonCategory == c.value;
                return ChoiceChip(
                  label: Text(
                    c.label,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.black,
                      fontSize: 11.sp,
                    ),
                  ),
                  selected: sel,
                  onSelected: (s) => setState(() => _reasonCategory = c.value),
                  selectedColor: AppColor.primaryColor,
                );
              }).toList(),
            ),

            SizedBox(height: 15.h),
            TextField(
              controller: _reason,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Why do you want a refund?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),

            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Images (${_images.length}/5)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.camera_alt),
                  label: Text("Add"),
                ),
              ],
            ),
            if (_images.isNotEmpty)
              SizedBox(
                height: 80.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(_images[i].path),
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(i)),
                          child: Icon(Icons.cancel, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 25.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: creating ? null : _submit,
                child: creating
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Submit Refund Request",
                        style: TextStyle(
                          color: Colors.white,
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
}

class _Category {
  final String value, label;
  final IconData icon;
  final Color color;
  const _Category(this.value, this.label, this.icon, this.color);
}
