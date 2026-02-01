// exchange_request_sheet.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:user_side/models/order/myOrderModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';

class ExchangeRequestSheet extends StatefulWidget {
  final Orders order;
  final List<Product> products;

  const ExchangeRequestSheet({super.key, required this.order, required this.products});

  @override
  State<ExchangeRequestSheet> createState() => _ExchangeRequestSheetState();
}

class _ExchangeRequestSheetState extends State<ExchangeRequestSheet> {
  final TextEditingController _reason = TextEditingController();
  Product? selected;

  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.products.isNotEmpty) selected = widget.products.first;
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (selectedImages.length >= 5) {
      AppToast.error("Maximum 5 images allowed");
      return;
    }

    final files = await _picker.pickMultiImage(imageQuality: 75);
    if (files.isEmpty) return;

    setState(() {
      final remaining = 5 - selectedImages.length;
      selectedImages.addAll(files.take(remaining));
    });
  }

  void _removeImage(int index) {
    setState(() => selectedImages.removeAt(index));
  }

  Future<List<String>> _imagesToBase64() async {
    final List<String> base64List = [];
    for (final x in selectedImages) {
      final bytes = await File(x.path).readAsBytes();
      // backend supports raw base64 OR data-uri, we send data-uri
      final b64 = base64Encode(bytes);
      base64List.add("data:image/jpg;base64,$b64");
    }
    return base64List;
  }

  Future<void> _submit() async {
    if (selected == null) {
      AppToast.error("Product not selected");
      return;
    }
    if (_reason.text.trim().isEmpty) {
      AppToast.error("Please enter exchange reason");
      return;
    }

    final provider = context.read<ExchangeProvider>();

    final buyerId = await LocalStorage.getUserId() ?? "";
    if (buyerId.isEmpty) {
      AppToast.error("User ID not found");
      return;
    }

    final imagesB64 = await _imagesToBase64();

    final ok = await provider.createRequest(
      buyerId: buyerId,
      orderId: widget.order.orderId ?? "",
      productId: selected!.productId ?? "",
      reason: _reason.text.trim(),
      images: imagesB64, // ✅ NEW
    );

    if (ok) {
      AppToast.success(provider.createModel?.message ?? "Exchange request submitted");
      if (mounted) Navigator.pop(context);
    } else {
      AppToast.error(provider.createModel?.message ?? "Failed to submit request");
    }
  }

  @override
  Widget build(BuildContext context) {
    final creating = context.watch<ExchangeProvider>().creating;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w, right: 16.w, top: 12.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Exchange Request", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 12.h),

            DropdownButtonFormField<Product>(
              value: selected,
              items: widget.products.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.name ?? "N/A"),
                );
              }).toList(),
              onChanged: creating ? null : (v) => setState(() => selected = v),
              decoration: const InputDecoration(labelText: "Select Product"),
            ),

            SizedBox(height: 10.h),
            TextField(
              controller: _reason,
              maxLines: 4,
              enabled: !creating,
              decoration: const InputDecoration(
                labelText: "Reason",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 12.h),

            // ✅ Images section
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Images (${selectedImages.length}/5)",
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: creating ? null : _pickImages,
                  child: const Text("Add Images"),
                )
              ],
            ),

            if (selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedImages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.h,
                  crossAxisSpacing: 8.w,
                ),
                itemBuilder: (_, i) {
                  final file = selectedImages[i];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(file.path),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: creating ? null : () => _removeImage(i),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Icon(Icons.close, size: 16.sp, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),

            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
                onPressed: creating ? null : _submit,
                child: creating
                    ? SizedBox(
                        height: 18.h,
                        width: 18.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Send Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
