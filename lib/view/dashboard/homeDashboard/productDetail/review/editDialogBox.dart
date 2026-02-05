import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/ProductAndCategoryModel/editReview_model.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/provider/productProvider/reviewEditOrDelete_provider.dart';

Future<void> openEditReviewDialog(
  BuildContext context,
  EditReview review,
  Function(int stars, String text) onUpdate,
) async {
  int initialRating = review.stars ?? 0;
  String initialText = review.text ?? "";

  final ValueNotifier<int> ratingNotifier = ValueNotifier(initialRating);
  final ValueNotifier<bool> isChangedNotifier = ValueNotifier(false);
  final TextEditingController controller = TextEditingController(
    text: initialText,
  );

  // Helper to check changed state
  void checkChanged() {
    bool changed =
        (ratingNotifier.value != initialRating) ||
        (controller.text.trim() != initialText);
    isChangedNotifier.value = changed;
  }

  await showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Edit Your Review",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // ⭐ Rating Row
            ValueListenableBuilder<int>(
              valueListenable: ratingNotifier,
              builder: (context, rating, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () {
                        ratingNotifier.value = i + 1;
                        checkChanged();
                      },
                      child: Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        size: 28,
                        color: Colors.amber,
                      ),
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 15),

            // ✍ Review Field
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (_) => checkChanged(),
            ),

            const SizedBox(height: 20),

            // 🔘 Update Button
            ValueListenableBuilder<bool>(
              valueListenable: isChangedNotifier,
              builder: (context, isChanged, _) {
                return ElevatedButton(
                  onPressed: isChanged
                      ? () async {
                          Navigator.pop(context);

                          final provider = Provider.of<ReviewActionProvider>(
                            context,
                            listen: false,
                          );

                          final userId = await LocalStorage.getUserId();

                          await provider.editReview(
                            reviewId: review.sId ?? "",
                            userId: userId.toString(),
                            text: controller.text.trim(),
                            stars: ratingNotifier.value.toString(),
                          );

                          if (provider.editResponse?.success == true) {
                            onUpdate(
                              ratingNotifier.value,
                              controller.text.trim(),
                            );
                          }
                        }
                      : null,
                  child: const Text("Update Review"),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );

  ratingNotifier.dispose();
  isChangedNotifier.dispose();
  controller.dispose();
}
