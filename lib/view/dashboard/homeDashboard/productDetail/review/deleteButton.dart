import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/provider/productProvider/reviewEditOrDelete_provider.dart';

Future<void> openDeleteReviewDialog(
  BuildContext context,
  Reviews review,
  Function() onDelete,
) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Review"),
      content: const Text("Do you want to delete your review?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);

            final provider = Provider.of<ReviewActionProvider>(
              context,
              listen: false,
            );

            final userId = await LocalStorage.getUserId();

            await provider.deleteReview(
              reviewId: review.sId ?? "",
              userId: userId.toString(),
            );

            if (provider.deleteResponse?.success == true) {
              onDelete();
            }
          },
          child: const Text("Yes", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
