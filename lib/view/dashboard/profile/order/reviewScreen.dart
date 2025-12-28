import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/createReview_provider.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customTextFeld.dart';

class ReviewScreen extends StatefulWidget {
  final String productId;
  const ReviewScreen({super.key, required this.productId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int selectedRating = 0;
  TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Review"),
        backgroundColor: AppColor.appimagecolor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Your Review",
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),

            // ⭐ Rating Stars
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

            SizedBox(height: 10.h),

            // ⭐ Review Text
            CustomTextField(
              height: 100.h,
              controller: reviewController,
              hintText: "Write your review...",
            ),

            SizedBox(height: 10.h),

            // ⭐ Submit Button
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: "Submit Review",
                onTap: () async {
                  if (selectedRating == 0 || reviewController.text.trim().isEmpty) return;

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
                    final getProductProvider = Provider.of<GetSingleProductProvider>(
                      context,
                      listen: false,
                    );

                    final reviewData = reviewProvider.reviewResponse?.review;
                    String userEmail = "User";

                    if (reviewData?.userId != null) {
                      userEmail = reviewData!.userId!.email ?? "User";
                    }

                    Reviews newReview = Reviews(
                      sId: reviewData?.sId ?? DateTime.now().toString(),
                      userEmail: userEmail.contains("@") ? userEmail.split("@").first : userEmail,
                      stars: selectedRating,
                      text: reviewController.text.trim(),
                    );

                    // Add to provider for immediate UI refresh
                    getProductProvider.addNewReview(newReview);

                    // Clear fields
                    setState(() {
                      selectedRating = 0;
                      reviewController.clear();
                    });

                    Navigator.pop(context); // Close screen after submission
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
