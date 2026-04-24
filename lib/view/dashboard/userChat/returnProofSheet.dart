// view/dashboard/userChat/returnProofSheet.dart
// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';

class ReturnProofSheet extends StatefulWidget {
  final String exchangeId;

  const ReturnProofSheet({super.key, required this.exchangeId});

  @override
  State<ReturnProofSheet> createState() => _ReturnProofSheetState();
}

class _ReturnProofSheetState extends State<ReturnProofSheet> {
  final TextEditingController _trackingNum = TextEditingController();
  final TextEditingController _courierName = TextEditingController();
  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _trackingNum.dispose();
    _courierName.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 3) {
      if (mounted) PremiumToast.error(context, "Maximum 3 images allowed");
      return;
    }
    final files = await _picker.pickMultiImage(imageQuality: 75);
    if (files.isEmpty) return;
    final remaining = 3 - _images.length;
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
    if (_trackingNum.text.trim().isEmpty) {
      PremiumToast.error(context, "Please enter tracking number");
      return;
    }
    if (_courierName.text.trim().isEmpty) {
      PremiumToast.error(context, "Please enter courier name");
      return;
    }

    final provider = context.read<ExchangeProvider>();
    final buyerId = await LocalStorage.getUserId() ?? "";

    final imagesB64 = await _imagesToBase64();

    final ok = await provider.uploadReturnProof(
      exchangeId: widget.exchangeId,
      buyerId: buyerId,
      trackingNumber: _trackingNum.text.trim(),
      courierName: _courierName.text.trim(),
      proofImages: imagesB64,
    );

    if (!mounted) return;

    if (ok) {
      PremiumToast.success(context, "Return information submitted!");
      Navigator.pop(context, true);
    } else {
      PremiumToast.error(
        context,
        provider.errorMessage ?? "Failed to submit return info",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploading = context.select<ExchangeProvider, bool>(
      (p) => p.uploadingProof,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Padding(
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
                "Ship Return Item",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Provide return shipping details to continue",
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
              SizedBox(height: 20.h),

              TextField(
                controller: _trackingNum,
                enabled: !uploading,
                decoration: InputDecoration(
                  labelText: "Tracking Number",
                  hintText: "Enter tracking number of your parcel",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _courierName,
                enabled: !uploading,
                decoration: InputDecoration(
                  labelText: "Courier Company",
                  hintText: "e.g. Leopard, TCS, M&P",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shipping Proof Photos (${_images.length}/3)",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: uploading ? null : _pickImages,
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
                          onTap: uploading
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

              SizedBox(height: 24.h),
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
                  onPressed: uploading ? null : _submit,
                  child: uploading
                      ? Utils.loadingLottie(size: 24)
                      : Text(
                          "Submit Shipping Proof",
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
      ),
    );
  }
}
