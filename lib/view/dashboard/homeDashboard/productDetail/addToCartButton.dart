import 'package:flutter/material.dart';
import 'package:user_side/models/cart_manager.dart';
import 'package:user_side/widgets/customButton.dart';

class AddToCart extends StatelessWidget {
  final List<String> imageUrls;
  final String name;
  final String description;
  final String price;
  final String brandName;
   AddToCart({super.key,
   required this.imageUrls,
    required this.name,
    required this.description,
    required this.price,
    required this.brandName,
  });
  List<String> selectedColors = [];
  List<String> selectedSizes = [];

  @override
  Widget build(BuildContext context) {
    return Expanded(
                    child: CustomButton(
                      text: "Add to Cart",
                      onTap: () {
                        final selectedColor = selectedColors.isNotEmpty
                            ? selectedColors.first
                            : null;
                        final selectedSize = selectedSizes.isNotEmpty
                            ? selectedSizes.first
                            : null;

                        if (selectedColor == null || selectedSize == null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Select Options"),
                              content: const Text(
                                "Please select both color and size first.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        final alreadyExists = CartManager.items.any(
                          (item) =>
                              item.name == name &&
                              item.colors == selectedColors &&
                              item.sizes == selectedSizes,
                        );

                        if (alreadyExists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "This product is already in favourite list",
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        CartManager.addToCart(
                          CartItem(
                            name: name,
                            imageUrl: imageUrls.first,
                            price: price,
                            colors: selectedColors,
                            sizes: selectedSizes,
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Product added to favourites!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
  }
}