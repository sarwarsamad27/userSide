import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart'
    hide UserId;

import 'package:user_side/models/ProductAndCategoryModel/editReview_model.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/review/deleteButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/review/editDialogBox.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/createReview_provider.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customTextFeld.dart';

class Review extends StatefulWidget {
  final String productId;
  final List<Reviews> reviews;

  const Review({super.key, required this.productId, required this.reviews});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  bool showAllReviews = false;
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();
  Map<String, bool> showEditDelete =
      {}; // Track temporary edit/delete for each review

  @override
  Widget build(BuildContext context) {
    List<Reviews> apiReviews = widget.reviews;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ADD REVIEW SECTION
          Text(
            "Add Your Review",
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),

          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() => selectedRating = index + 1);
                },
                child: Icon(
                  Icons.star,
                  size: 26.sp,
                  color: index < selectedRating
                      ? AppColor.primaryColor
                      : Colors.grey.shade400,
                ),
              );
            }),
          ),

          CustomTextField(
            height: 100.h,
            controller: reviewController,
            hintText: "Write your review...",
          ),

          SizedBox(height: 10.h),

          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: "Submit Review",
              onTap: () async {
                if (selectedRating == 0 || reviewController.text.trim().isEmpty)
                  return;

                final userId = await LocalStorage.getUserId();

                final reviewProvider = Provider.of<CreateReviewProvider>(
                  context,
                  listen: false,
                );

                await reviewProvider.createReview(
                  productId: widget.productId,
                  userId: userId.toString(),
                  stars: selectedRating.toString(),
                  text: reviewController.text.trim(),
                );

                if (reviewProvider.reviewResponse?.success == true) {
                  final getProductProvider =
                      Provider.of<GetSingleProductProvider>(
                        context,
                        listen: false,
                      );

                  // ⭐ Safely get email
                  final dynamic userMap =
                      reviewProvider.reviewResponse?.review?.userId;
                  String userEmail = "User";

                  if (userMap != null) {
                    if (userMap is UserId) {
                      userEmail = userMap.email ?? "User";
                    } else if (userMap is Map) {
                      userEmail =
                          userMap['email']?.toString() ??
                          userMap['userEmail']?.toString() ??
                          "User";
                    } else if (userMap is String) {
                      userEmail = userMap;
                    } else {
                      try {
                        final emailValue = (userMap as dynamic).email;
                        if (emailValue != null)
                          userEmail = emailValue.toString();
                      } catch (_) {}
                    }
                  }
                  final realReviewId =
                      reviewProvider.reviewResponse?.review?.sId ?? "";
                  Reviews newReview = Reviews(
                    sId: realReviewId,
                    userEmail: userEmail.contains("@")
                        ? userEmail.split("@").first
                        : userEmail,
                    stars: selectedRating,
                    text: reviewController.text.trim(),
                  );

                  // ⭐ Insert into provider (auto UI refresh)
                  getProductProvider.addNewReview(newReview);

                  // ⭐ Show temporary edit/delete
                  showTemporaryEditDelete(
                    newReview.sId ?? DateTime.now().toString(),
                  );

                  // Clear fields
                  setState(() {
                    selectedRating = 0;
                    reviewController.clear();
                  });
                }
              },
            ),
          ),

          SizedBox(height: 20.h),

          Text(
            "Customer Reviews",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),

          apiReviews.isEmpty
              ? Text(
                  "No Review Yet",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Column(
                  children: List.generate(
                    showAllReviews
                        ? apiReviews.length
                        : (apiReviews.length > 3 ? 3 : apiReviews.length),
                    (index) {
                      final r = apiReviews[index];

                      bool canEditDelete = showEditDelete[r.sId] ?? false;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// USER & RATING ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (r.userEmail != null &&
                                          r.userEmail!.contains("@"))
                                      ? r.userEmail!.split("@").first
                                      : r.userEmail ?? "User",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < (r.stars ?? 0)
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 18.sp,
                                      color: Colors.amber,
                                    );
                                  }),
                                ),
                              ],
                            ),

                            SizedBox(height: 6.h),

                            Text(
                              r.text ?? "",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                            ),

                            if (canEditDelete || r.userEmail == "StaticUser")
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      openEditReviewDialog(
                                        context,
                                        EditReview(
                                          sId: r.sId,
                                          stars: r.stars,
                                          text: r.text,
                                        ),
                                        (updatedStars, updatedText) {
                                          setState(() {
                                            r.stars = updatedStars;
                                            r.text = updatedText;
                                          });
                                        },
                                      );
                                    },

                                    child: Text("Edit"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      openDeleteReviewDialog(context, r, () {
                                        setState(() {
                                          widget.reviews.removeWhere(
                                            (rev) => rev.sId == r.sId,
                                          );
                                        });
                                      });
                                    },

                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

          if (apiReviews.length > 3)
            GestureDetector(
              onTap: () => setState(() => showAllReviews = !showAllReviews),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Text(
                  showAllReviews ? "See Less" : "See More",
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Show edit/delete temporarily for 5 minutes
  void showTemporaryEditDelete(String reviewId) {
    setState(() {
      showEditDelete[reviewId] = true;
    });

    Future.delayed(Duration(minutes: 5), () {
      setState(() {
        showEditDelete[reviewId] = false;
      });
    });
  }
}
