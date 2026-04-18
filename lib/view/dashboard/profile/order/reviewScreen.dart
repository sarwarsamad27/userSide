// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/review_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/createReview_provider.dart';

class ReviewScreen extends StatelessWidget {
  final String productId;
  const ReviewScreen({super.key, required this.productId});

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
          title: Text(
            "Add Review",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
        ),
        body: Consumer3<ReviewFormProvider, CreateReviewProvider, ReviewProvider>(
          builder: (context, form, reviewProvider, reviewedProvider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER CARD ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.primaryColor.withOpacity(0.9),
                          AppColor.primaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.rate_review_rounded,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Share Your Experience",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    "Your feedback helps others decide",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ── RATING CARD ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "Rate Your Experience",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Stars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starValue = index + 1;
                            final isSelected = index < form.selectedRating;
                            return GestureDetector(
                              onTap: () => form.setRating(starValue),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Icon(
                                  isSelected
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: isSelected ? 42.sp : 36.sp,
                                  color: isSelected
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              ),
                            );
                          }),
                        ),

                        SizedBox(height: 12.h),

                        // Rating Label
                        if (form.selectedRating > 0)
                          Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _ratingLabel(form.selectedRating),
                                key: ValueKey(form.selectedRating),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _ratingColor(form.selectedRating),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── REVIEW TEXT CARD ─────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              color: AppColor.primaryColor,
                              size: 18.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "Write Your Review",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        TextField(
                          controller: form.reviewController,
                          maxLines: 5,
                          minLines: 4,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                "Tell others what you think about this product...",
                            hintStyle: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[400],
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF6F7FB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide(
                                color: AppColor.primaryColor.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(14.w),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── SUBMIT BUTTON ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: !form.canSubmit
                          ? null
                          : () async {
                              if (!form.canSubmit) return;

                              final userId = await LocalStorage.getUserId();

                              await reviewProvider.createReview(
                                productId: productId,
                                userId: userId.toString(),
                                stars: form.selectedRating.toString(),
                                text: form.trimmedText,
                              );

                              if (reviewProvider.reviewResponse?.success ==
                                  true) {
                                final getProductProvider =
                                    Provider.of<GetSingleProductProvider>(
                                      context,
                                      listen: false,
                                    );

                                final reviewData =
                                    reviewProvider.reviewResponse?.review;
                                String userEmail = "User";

                                if (reviewData?.userId != null) {
                                  userEmail =
                                      reviewData!.userId!.email ?? "User";
                                }

                                Reviews newReview = Reviews(
                                  sId:
                                      reviewData?.sId ??
                                      DateTime.now().toString(),
                                  userEmail: userEmail.contains("@")
                                      ? userEmail.split("@").first
                                      : userEmail,
                                  stars: form.selectedRating,
                                  text: form.trimmedText,
                                );

                                getProductProvider.addNewReview(newReview);
                                await reviewedProvider.markReviewed(productId);
                                form.reset();
                                await reviewedProvider.showSuccessDialog(
                                  context,
                                );
                                Navigator.pop(context, true);
                              }
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          gradient: form.canSubmit
                              ? LinearGradient(
                                  colors: [
                                    AppColor.primaryColor.withOpacity(0.9),
                                    AppColor.primaryColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: form.canSubmit ? null : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: form.canSubmit
                              ? [
                                  BoxShadow(
                                    color: AppColor.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              color: form.canSubmit
                                  ? Colors.white
                                  : Colors.grey[400],
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Submit Review",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: form.canSubmit
                                    ? Colors.white
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Hint text
                  if (!form.canSubmit)
                    Center(
                      child: Text(
                        "Please select a rating and write your review",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SizedBox(height: 30.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return "😞  Poor";
      case 2:
        return "😐  Fair";
      case 3:
        return "🙂  Good";
      case 4:
        return "😊  Very Good";
      case 5:
        return "🤩  Excellent!";
      default:
        return "";
    }
  }

  Color _ratingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
