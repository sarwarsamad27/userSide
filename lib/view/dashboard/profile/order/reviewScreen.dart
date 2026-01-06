import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/review_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/createReview_provider.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customTextFeld.dart';

class ReviewScreen extends StatelessWidget {
  final String productId;
  const ReviewScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewFormProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Review"),
          backgroundColor: AppColor.appimagecolor,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Consumer3<ReviewFormProvider, CreateReviewProvider, ReviewProvider>(
            builder: (context, form, reviewProvider, reviewedProvider, child) {
              return Column(
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

                  /// ⭐ Rating Stars
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return GestureDetector(
                        onTap: () => form.setRating(starValue),
                        child: Icon(
                          Icons.star,
                          size: 26.sp,
                          color: index < form.selectedRating
                              ? AppColor.primaryColor
                              : Colors.grey.shade400,
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 10.h),

                  /// ⭐ Review Text
                  CustomTextField(
                    height: 100.h,
                    controller: form.reviewController,
                    hintText: "Write your review...",
                  ),

                  SizedBox(height: 10.h),

                  /// ⭐ Submit Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      text: "Submit Review",
                      onTap: () async {
                        if (!form.canSubmit) return;

                        final userId = await LocalStorage.getUserId();

                        await reviewProvider.createReview(
                          productId: productId,
                          userId: userId.toString(),
                          stars: form.selectedRating.toString(),
                          text: form.trimmedText,
                        );

                        if (reviewProvider.reviewResponse?.success == true) {
                          final getProductProvider =
                              Provider.of<GetSingleProductProvider>(
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
                            userEmail: userEmail.contains("@")
                                ? userEmail.split("@").first
                                : userEmail,
                            stars: form.selectedRating,
                            text: form.trimmedText,
                          );

                          /// Add to provider for immediate UI refresh
                          getProductProvider.addNewReview(newReview);

                          /// Mark reviewed in SharedPreferences (and provider memory)
                          await reviewedProvider.markReviewed(productId);

                          /// Clear fields
                          form.reset();

                          Navigator.pop(context, true);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}