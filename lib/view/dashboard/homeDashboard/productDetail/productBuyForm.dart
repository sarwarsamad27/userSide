import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customTextFeld.dart';

class ProductBuyForm extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String price;
  final String color;
  final String size;

  const ProductBuyForm({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.color,
    required this.size,
  });

  @override
  State<ProductBuyForm> createState() => _ProductBuyFormState();
}

class _ProductBuyFormState extends State<ProductBuyForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _additionalNoteController =
      TextEditingController();

  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        widget.imageUrl,
                        height: 60.h,
                        width: 60.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            widget.price,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            "Color: ${widget.color}, Size: ${widget.size}",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // 🔹 Quantity Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                      child: Container(
                        height: 35.h,
                        width: 35.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColor.primaryColor),
                        ),
                        child: const Icon(Icons.remove, size: 20),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Text(
                      "$quantity",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    InkWell(
                      onTap: () {
                        setState(() {
                          quantity++;
                        });
                      },
                      child: Container(
                        height: 35.h,
                        width: 35.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColor.primaryColor),
                        ),
                        child: const Icon(Icons.add, size: 20),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // 🔹 Form Fields
                Expanded(
                  child: Center(
                    child: CustomAppContainer(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              hintText: "Enter your name",
                              headerText: "Full Name",
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              controller: _emailController,
                              hintText: "Enter your email",
                              headerText: "Email Address",
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              controller: _phoneController,
                              hintText: "Enter your phone number",
                              headerText: "Phone Number",
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              controller: _addressController,
                              hintText: "Enter your address",
                              headerText: "Address",
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              controller: _additionalNoteController,
                              hintText: "Write additional notes",
                              headerText: "Order Notes",
                              height: 120.h,
                            ),
                            SizedBox(height: 30.h),
                            CustomButton(
                              text: "Place Order",
                              onTap: () {
                                // Handle order placement here
                                debugPrint(
                                  "Order placed with Quantity: $quantity",
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
