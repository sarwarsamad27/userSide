// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/review_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/createReview_provider.dart';
import 'package:video_player/video_player.dart';

class ReviewScreen extends StatelessWidget {
  final String productId;
  final String orderId;
  const ReviewScreen({super.key, required this.productId, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewFormProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text("Add Review", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
        ),
        body: Consumer3<ReviewFormProvider, CreateReviewProvider, ReviewProvider>(
          builder: (context, form, reviewProvider, reviewedProvider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER ──
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.primaryColor.withOpacity(0.9), AppColor.primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [BoxShadow(color: AppColor.primaryColor.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: Icon(Icons.rate_review_rounded, color: Colors.white, size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Share Your Experience", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                              SizedBox(height: 3.h),
                              Text("Your feedback helps others decide", style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ── RATING ──
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 18.sp),
                          SizedBox(width: 6.w),
                          Text("Rate Your Experience", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
                        ]),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final v = i + 1;
                            return GestureDetector(
                              onTap: () => form.setRating(v),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Icon(
                                  i < form.selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                                  size: i < form.selectedRating ? 42.sp : 36.sp,
                                  color: i < form.selectedRating ? Colors.amber : Colors.grey[300],
                                ),
                              ),
                            );
                          }),
                        ),
                        if (form.selectedRating > 0) ...[
                          SizedBox(height: 12.h),
                          Center(
                            child: Text(
                              _ratingLabel(form.selectedRating),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _ratingColor(form.selectedRating)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── REVIEW TEXT ──
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.edit_note_rounded, color: AppColor.primaryColor, size: 18.sp),
                          SizedBox(width: 6.w),
                          Text("Write Your Review", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
                        ]),
                        SizedBox(height: 14.h),
                        TextField(
                          controller: form.reviewController,
                          maxLines: 5,
                          minLines: 4,
                          style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: "Tell others what you think about this product...",
                            hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFFF6F7FB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide(color: AppColor.primaryColor.withOpacity(0.4), width: 1.5),
                            ),
                            contentPadding: EdgeInsets.all(14.w),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── IMAGES (up to 5) ──
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Icon(Icons.photo_library_outlined, color: AppColor.primaryColor, size: 18.sp),
                              SizedBox(width: 6.w),
                              Text("Add Photos (${form.images.length}/5)", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
                            ]),
                            if (form.images.length < 5)
                              TextButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickMultiImage(imageQuality: 70);
                                  if (picked.isNotEmpty) form.addImages(picked.map((x) => File(x.path)).toList());
                                },
                                icon: Icon(Icons.add_photo_alternate_outlined, size: 16.sp),
                                label: const Text("Add"),
                              ),
                          ],
                        ),
                        if (form.images.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          SizedBox(
                            height: 80.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: form.images.length,
                              separatorBuilder: (_, __) => SizedBox(width: 8.w),
                              itemBuilder: (_, i) => Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.file(form.images[i], width: 80.w, height: 80.h, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 0, right: 0,
                                    child: GestureDetector(
                                      onTap: () => form.removeImage(i),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── VIDEO (optional, 30 sec) ──
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Icon(Icons.videocam_outlined, color: AppColor.primaryColor, size: 18.sp),
                              SizedBox(width: 6.w),
                              Text("Add Video (max 30 sec)", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
                            ]),
                            if (form.video == null)
                              TextButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 30));
                                  if (picked != null) form.setVideo(File(picked.path));
                                },
                                icon: Icon(Icons.add_circle_outline, size: 16.sp),
                                label: const Text("Add"),
                              ),
                          ],
                        ),
                        if (form.video != null) ...[
                          SizedBox(height: 10.h),
                          _ReviewVideoPreview(file: form.video!, onRemove: () => form.setVideo(null)),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── SUBMIT ──
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: !form.canSubmit
                          ? null
                          : () async {
                              if (!form.canSubmit) return;
                              final userId = await LocalStorage.getUserId();

                              // Encode images to base64
                              final b64Images = <String>[];
                              for (final img in form.images) {
                                final bytes = await img.readAsBytes();
                                b64Images.add("data:image/jpg;base64,${base64Encode(bytes)}");
                              }

                              // Encode video to base64
                              String? b64Video;
                              if (form.video != null) {
                                final bytes = await form.video!.readAsBytes();
                                b64Video = "data:video/mp4;base64,${base64Encode(bytes)}";
                              }

                              await reviewProvider.createReview(
                                productId: productId,
                                userId: userId.toString(),
                                stars: form.selectedRating.toString(),
                                text: form.trimmedText,
                                images: b64Images,
                                video: b64Video,
                              );

                              if (reviewProvider.reviewResponse?.success == true) {
                                final getProductProvider = Provider.of<GetSingleProductProvider>(context, listen: false);
                                final reviewData = reviewProvider.reviewResponse?.review;
                                String userEmail = "User";
                                if (reviewData?.userId != null) userEmail = reviewData!.userId!.email ?? "User";

                                Reviews newReview = Reviews(
                                  sId: reviewData?.sId ?? DateTime.now().toString(),
                                  userEmail: userEmail.contains("@") ? userEmail.split("@").first : userEmail,
                                  stars: form.selectedRating,
                                  text: form.trimmedText,
                                  images: reviewData?.images ?? [],
                                  video: reviewData?.video,
                                );
                                getProductProvider.addNewReview(newReview);
                                await reviewedProvider.markReviewed(orderId);
                                form.reset();
                                await reviewedProvider.showSuccessDialog(context);
                                Navigator.pop(context, true);
                              }
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          gradient: form.canSubmit
                              ? LinearGradient(
                                  colors: [AppColor.primaryColor.withOpacity(0.9), AppColor.primaryColor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: form.canSubmit ? null : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: form.canSubmit
                              ? [BoxShadow(color: AppColor.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: form.canSubmit ? Colors.white : Colors.grey[400], size: 18.sp),
                            SizedBox(width: 8.w),
                            Text("Submit Review", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: form.canSubmit ? Colors.white : Colors.grey[400])),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (!form.canSubmit) ...[
                    SizedBox(height: 12.h),
                    Center(
                      child: Text(
                        "Please select a rating and write your review",
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  SizedBox(height: 30.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return "😞  Poor";
      case 2: return "😐  Fair";
      case 3: return "🙂  Good";
      case 4: return "😊  Very Good";
      case 5: return "🤩  Excellent!";
      default: return "";
    }
  }

  Color _ratingColor(int r) {
    switch (r) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.amber;
      case 4: return Colors.lightGreen;
      case 5: return Colors.green;
      default: return Colors.grey;
    }
  }
}

// ── Inline video preview for review screen ──────────────────────────────────
class _ReviewVideoPreview extends StatefulWidget {
  final File file;
  final VoidCallback onRemove;
  const _ReviewVideoPreview({required this.file, required this.onRemove});

  @override
  State<_ReviewVideoPreview> createState() => _ReviewVideoPreviewState();
}

class _ReviewVideoPreviewState extends State<_ReviewVideoPreview> {
  late VideoPlayerController _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.file(widget.file)
      ..initialize().then((_) { if (mounted) setState(() => _ready = true); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () { _ready ? (_ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play()) : null; setState(() {}); },
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10.r)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_ready)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: AspectRatio(aspectRatio: _ctrl.value.aspectRatio, child: VideoPlayer(_ctrl)),
                  )
                else
                  const CircularProgressIndicator(color: Colors.white),
                if (_ready && !_ctrl.value.isPlaying)
                  const Icon(Icons.play_circle_fill, color: Colors.white70, size: 44),
              ],
            ),
          ),
        ),
        Positioned(
          top: 4, right: 4,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
