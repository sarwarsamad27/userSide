import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/review/deleteButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/review/editDialogBox.dart';
import 'package:user_side/models/ProductAndCategoryModel/editReview_model.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';

class Review extends StatefulWidget {
  final String productId;
  final List<Reviews> reviews;

  const Review({super.key, required this.productId, required this.reviews});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  bool showAllReviews = false;
  Map<String, bool> showEditDelete =
      {}; // Track temporary edit/delete for each review

  // NEW: Track view/hide reply per review
  final Map<String, bool> showReply = {};

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    int hour = date.hour;
    String period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12;
    if (hour == 0) hour = 12;
    String minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "${date.day.toString().padLeft(2, '0')} "
          "${_monthName(date.month)} "
          "${date.year} - ${_formatTime(date)}";
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetSingleProductProvider>();
    final data = provider.productData!;
    List<Reviews> apiReviews = widget.reviews;

    // ✅ If no reviews, hide the whole section (no heading, no "No Review Yet")
    if (apiReviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Customer Reviews",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),

          // ✅ Now always show reviews list (because apiReviews is not empty)
          Column(
            children: List.generate(
              showAllReviews
                  ? apiReviews.length
                  : (apiReviews.length > 3 ? 3 : apiReviews.length),
              (index) {
                final r = apiReviews[index];
                bool canEditDelete = showEditDelete[r.sId] ?? false;

                final bool isReplyVisible = showReply[r.sId ?? ""] ?? false;

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (r.userEmail != null && r.userEmail!.contains("@"))
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

                      if (r.repliedAt != null)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            formatDate(r.createdAt!),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
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
                              child: const Text("Edit"),
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
                              child: const Text("Delete"),
                            ),
                          ],
                        ),

                      if (r.replyText != null && r.replyText!.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                final key = r.sId ?? "";
                                showReply[key] = !(showReply[key] ?? false);
                              });
                            },
                            child: Text(
                              isReplyVisible ? "Hide Reply" : "View Reply",
                              style: TextStyle(
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),

                      if ((r.replyText != null && r.replyText!.isNotEmpty) &&
                          isReplyVisible)
                        Container(
                          margin: EdgeInsets.only(top: 10.h),
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.reply,
                                color: AppColor.primaryColor,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.profileName ?? "Seller",
                                      style: TextStyle(
                                        color: AppColor.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      r.replyText ?? "",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    if (r.repliedAt != null)
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          formatDate(r.repliedAt!),
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

    Future.delayed(const Duration(minutes: 5), () {
      setState(() {
        showEditDelete[reviewId] = false;
      });
    });
  }
}
