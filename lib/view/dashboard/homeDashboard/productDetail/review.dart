import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customTextFeld.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  List<Map<String, dynamic>> reviews = [
    {
      "user": "Ali Raza",
      "rating": 5,
      "review": "Great product, loved the quality!",
    },
    {
      "user": "Hassan",
      "rating": 4,
      "review": "Delivery on time, totally satisfied.",
    },
    {"user": "Zara", "rating": 5, "review": "Material is very comfortable."},
    {
      "user": "Hamza",
      "rating": 4,
      "review": "Color is exactly the same as shown!",
    },
  ];

  bool showAllReviews = false;
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Add Your Review",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10.h),

        // ⭐ Rating stars
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedRating = index + 1;
                });
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

        // TextField for review
        CustomTextField(
          height: 100.h,
          controller: reviewController,
          hintText: "Write your review...",
        ),
        SizedBox(height: 10.h),

        Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            onTap: () {
              if (selectedRating > 0 &&
                  reviewController.text.trim().isNotEmpty) {
                setState(() {
                  reviews.insert(0, {
                    "user": "You",
                    "rating": selectedRating,
                    "review": reviewController.text.trim(),
                  });
                  selectedRating = 0;
                  reviewController.clear();
                });
              }
            },
            text: 'Submit Review',
          ),
        ),
        SizedBox(height: 20.h),

        // ╔══════════════ REVIEW CARDS LIST ══════════════╗
        Text(
          "Customer Reviews",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 12.h),

        Column(
          children: List.generate(
            showAllReviews
                ? reviews.length
                : (reviews.length > 3 ? 3 : reviews.length),
            (index) {
              final r = reviews[index];
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          r['user'],
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < r['rating']
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 18.sp,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                            SizedBox(width: 8.w),
                            if (r['user'] == "You") ...[
                              // Edit button
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 20.sp,
                                  color: AppColor.primaryColor,
                                ),
                                onPressed: () {
                                  reviewController.text = r['review'];
                                  selectedRating = r['rating'];
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text("Edit Review"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: List.generate(5, (i) {
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedRating = i + 1;
                                                  });
                                                },
                                                child: Icon(
                                                  i < selectedRating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                ),
                                              );
                                            }),
                                          ),
                                          TextField(
                                            controller: reviewController,
                                            decoration: InputDecoration(
                                              hintText: "Edit your review",
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              r['review'] =
                                                  reviewController.text;
                                              r['rating'] = selectedRating;
                                              reviewController.clear();
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text("Save"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              // Delete button
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  size: 20.sp,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    reviews.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 6.h),

                    Text(
                      r['review'],
                      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        if (reviews.length > 3)
          GestureDetector(
            onTap: () {
              setState(() {
                showAllReviews = !showAllReviews;
              });
            },
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
        // ╚══════════════════════════════════════════════╝
      ],
    );
  }
}
