import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/models/cart_manager.dart';

class FavouiteScreen extends StatefulWidget {
  const FavouiteScreen({super.key});

  @override
  State<FavouiteScreen> createState() => _FavouiteScreenState();
}

class _FavouiteScreenState extends State<FavouiteScreen> {
  @override
  Widget build(BuildContext context) {
    final items = CartManager.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favourites"),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? const Center(child: Text("No products added yet"))
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          item.imageUrl,
                          height: 70.h,
                          width: 70.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600)),
                            Text(item.price,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87)),
                            Text("Color: ${item.color}, Size: ${item.size}",
                                style: TextStyle(
                                    fontSize: 13.sp, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    CartManager.decreaseQuantity(item);
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
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    CartManager.increaseQuantity(item);
                                  });
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
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
    );
  }
}
