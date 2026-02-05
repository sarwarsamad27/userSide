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
  final ValueNotifier<int> _versionNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _showAllReviewsNotifier = ValueNotifier(false);

  // Using ValueNotifier with immutable maps for updates
  final ValueNotifier<Map<String, bool>> _showReplyNotifier = ValueNotifier({});
  final ValueNotifier<Map<String, bool>> _showEditDeleteNotifier =
      ValueNotifier({});

  @override
  void dispose() {
    _versionNotifier.dispose();
    _showAllReviewsNotifier.dispose();
    _showReplyNotifier.dispose();
    _showEditDeleteNotifier.dispose();
    super.dispose();
  }

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
    // widget.reviews is a reference.
    // We listen to _versionNotifier to know when to rebuild this if contents changed in place.

    return ValueListenableBuilder<int>(
      valueListenable: _versionNotifier,
      builder: (context, version, _) {
        final apiReviews = widget.reviews;

        // ✅ If no reviews, hide the whole section
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

              ValueListenableBuilder<bool>(
                valueListenable: _showAllReviewsNotifier,
                builder: (context, showAllReviews, _) {
                  final int count = showAllReviews
                      ? apiReviews.length
                      : (apiReviews.length > 3 ? 3 : apiReviews.length);

                  return Column(
                    children: [
                      Column(
                        children: List.generate(count, (index) {
                          final r = apiReviews[index];
                          final reviewId = r.sId ?? "";

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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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

                                // Edit/Delete Buttons
                                ValueListenableBuilder<Map<String, bool>>(
                                  valueListenable: _showEditDeleteNotifier,
                                  builder: (context, editDeleteMap, _) {
                                    bool canEditDelete =
                                        editDeleteMap[reviewId] ?? false;

                                    if (canEditDelete ||
                                        r.userEmail == "StaticUser") {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                                  // Update locally and notify
                                                  r.stars = updatedStars;
                                                  r.text = updatedText;
                                                  _versionNotifier.value++;
                                                },
                                              );
                                            },
                                            child: const Text("Edit"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              openDeleteReviewDialog(
                                                context,
                                                r,
                                                () {
                                                  widget.reviews.removeWhere(
                                                    (rev) => rev.sId == r.sId,
                                                  );
                                                  _versionNotifier.value++;
                                                },
                                              );
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),

                                // Reply Button
                                if (r.replyText != null &&
                                    r.replyText!.isNotEmpty)
                                  ValueListenableBuilder<Map<String, bool>>(
                                    valueListenable: _showReplyNotifier,
                                    builder: (context, replyMap, _) {
                                      final isReplyVisible =
                                          replyMap[reviewId] ?? false;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () {
                                                final newMap =
                                                    Map<String, bool>.from(
                                                      replyMap,
                                                    );
                                                newMap[reviewId] =
                                                    !isReplyVisible;
                                                _showReplyNotifier.value =
                                                    newMap;
                                              },
                                              child: Text(
                                                isReplyVisible
                                                    ? "Hide Reply"
                                                    : "View Reply",
                                                style: TextStyle(
                                                  color: AppColor.primaryColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (isReplyVisible)
                                            Container(
                                              margin: EdgeInsets.only(
                                                top: 10.h,
                                              ),
                                              padding: EdgeInsets.all(10.w),
                                              decoration: BoxDecoration(
                                                color: AppColor.primaryColor
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.reply,
                                                    color:
                                                        AppColor.primaryColor,
                                                    size: 18.sp,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          data.profileName ??
                                                              "Seller",
                                                          style: TextStyle(
                                                            color: AppColor
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13.sp,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4.h),
                                                        Text(
                                                          r.replyText ?? "",
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: Colors
                                                                .grey[800],
                                                          ),
                                                        ),
                                                        if (r.repliedAt != null)
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: Text(
                                                              formatDate(
                                                                r.repliedAt!,
                                                              ),
                                                              style: TextStyle(
                                                                fontSize: 11.sp,
                                                                color:
                                                                    Colors.grey,
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
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),

                      if (apiReviews.length > 3)
                        GestureDetector(
                          onTap: () =>
                              _showAllReviewsNotifier.value = !showAllReviews,
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
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show edit/delete temporarily for 5 minutes
  void showTemporaryEditDelete(String reviewId) {
    final currentMap = _showEditDeleteNotifier.value;
    final newMap = Map<String, bool>.from(currentMap);
    newMap[reviewId] = true;
    _showEditDeleteNotifier.value = newMap;

    Future.delayed(const Duration(minutes: 5), () {
      if (!mounted) return;
      final current = _showEditDeleteNotifier.value;
      final nextMap = Map<String, bool>.from(current);
      nextMap[reviewId] = false;
      _showEditDeleteNotifier.value = nextMap;
    });
  }
}
