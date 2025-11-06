import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/models/cart_manager.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productBuyForm.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';

class FavouiteScreen extends StatefulWidget {
  const FavouiteScreen({super.key});

  @override
  State<FavouiteScreen> createState() => _FavouiteScreenState();
}

class _FavouiteScreenState extends State<FavouiteScreen> {
  double getTotalAmount() {
    double total = 0;
    for (var item in CartManager.items) {
      // Parse ₹999 format price to double
      final priceValue =
          double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      total += priceValue * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final items = CartManager.items;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Favourites ❤️",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: CustomBgContainer(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          "No products added yet",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final priceValue =
                              double.tryParse(
                                item.price.replaceAll(RegExp(r'[^0-9.]'), ''),
                              ) ??
                              0;
                          final total = priceValue * item.quantity;

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: AppColor.primaryColor.withOpacity(.3),
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 🖼 Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.network(
                                    item.imageUrl,
                                    height: 80.h,
                                    width: 80.w,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 12.w),

                                /// 📦 Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        item.price,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "Colors: ${item.colors.join(', ')}",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        "Sizes: ${item.sizes.join(', ')}",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 6.h),

                                      /// 💰 Total Amount
                                      Text(
                                        "Total: Rs. x${total.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// ➕➖ Quantity Controls + Delete
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: AppColor.primaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              CartManager.decreaseQuantity(
                                                item,
                                              );
                                            });
                                          },
                                        ),
                                        Text(
                                          "${item.quantity}",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: AppColor.primaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              CartManager.increaseQuantity(
                                                item,
                                              );
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          CartManager.removeFromCart(item);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // 🔹 Bottom Summary & Checkout
              if (items.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Grand Total:",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Rs. ${getTotalAmount().toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.appbackgroundcolor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      CustomButton(
                        text: "Proceed to Checkout (${items.length})",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductBuyForm(favouriteItems: items),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
