import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/models/cart_manager.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productBuyForm.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productImage.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/productCard.dart';

class ProductDetailScreen extends StatefulWidget {
  final List<String> imageUrls;
  final String name;
  final String description;
  final String color;
  final String size;
  final String price;
  final String brandName;

  const ProductDetailScreen({
    super.key,
    required this.imageUrls,
    required this.name,
    required this.description,
    required this.color,
    required this.size,
    required this.price,
    required this.brandName,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedColor;
  String? selectedSize;

  final List<String> availableColors = ["Red", "Blue", "Black", "White"];
  final List<String> availableSizes = ["S", "M", "L", "XL"];

  @override
  Widget build(BuildContext context) {
    final relatedProducts = [
      {
        'name': 'Running Shoes',
        'price': 'PKR 4,999',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
      {
        'name': 'Sneakers',
        'price': 'PKR 6,499',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
      {
        'name': 'Sports Jacket',
        'price': 'PKR 8,999',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
    ];

    final otherProducts = [
      {
        'name': 'T-Shirt',
        'price': 'PKR 2,999',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
      {
        'name': 'Joggers',
        'price': 'PKR 3,499',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
      {
        'name': 'Cap',
        'price': 'PKR 999',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Product Images
                  ProductImage(imageUrls: widget.imageUrls),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 18.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Brand Section
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24.r,
                              backgroundImage: const NetworkImage(
                                "https://images.seeklogo.com/logo-png/9/1/nike-logo-png_seeklogo-99478.png",
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              widget.brandName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // 🔹 Product Title and Price
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.price,
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // 🔹 Color Selection
                        Text(
                          "Select Color",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          children: availableColors.map((color) {
                            final isSelected = color == selectedColor;
                            return ChoiceChip(
                              label: Text(color),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() => selectedColor = color);
                              },
                              selectedColor: Colors.black,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.h),

                        // 🔹 Size Selection
                        Text(
                          "Select Size",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          children: availableSizes.map((size) {
                            final isSelected = size == selectedSize;
                            return ChoiceChip(
                              label: Text(size),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() => selectedSize = size);
                              },
                              selectedColor: Colors.black,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 20.h),

                        // 🔹 Description
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.description,
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.5,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Related Products
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      "Related Products",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 250.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: relatedProducts.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (context, index) {
                        final item = relatedProducts[index];
                        return SizedBox(
                          width: 160.w,
                          child: ProductCard(
                            name: item['name']!,
                            price: item['price']!,
                            imageUrl: item['imageUrl']!,
                            onTap: () {},
                          ),
                        );
                      },
                    ),
                  ),

                  // 🔹 Other Products
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    child: Text(
                      "Other Products",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: otherProducts.length,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final item = otherProducts[index];
                      return ProductCard(
                        name: item['name']!,
                        price: item['price']!,
                        imageUrl: item['imageUrl']!,
                        onTap: () {},
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Bottom Buy/Add Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Add to Cart",
                      onTap: () {
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

                        // ✅ Check if product already exists in favourites
                        final alreadyExists = CartManager.items.any(
                          (item) =>
                              item.name == widget.name &&
                              item.color == selectedColor &&
                              item.size == selectedSize,
                        );

                        if (alreadyExists) {
                          // ✅ Show Already Exists Message
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

                        // ✅ Add Product to Cart (if not exists)
                        CartManager.addToCart(
                          CartItem(
                            name: widget.name,
                            imageUrl: widget.imageUrls.first,
                            price: widget.price,
                            color: selectedColor!,
                            size: selectedSize!,
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
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      text: "Buy Now",
                      onTap: () {
                        if (selectedColor == null || selectedSize == null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Select Options"),
                              content: const Text(
                                "Please select both color and size before proceeding.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductBuyForm(
                                imageUrl: widget.imageUrls.first,
                                name: widget.name,
                                price: widget.price,
                                color: selectedColor!,
                                size: selectedSize!,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
