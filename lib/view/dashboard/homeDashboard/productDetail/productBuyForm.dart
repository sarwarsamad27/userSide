import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/view/auth/AuthLoginGate.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/getFavourite_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/createOrder_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customTextFeld.dart';

class ProductBuyForm extends StatefulWidget {
  final String? imageUrl;
  final String? name;
  final String? price;
  final List<String>? colors;
  final List<String>? sizes;
  final List<String> productId;
  final List<dynamic>? favouriteItems;

  const ProductBuyForm({
    super.key,
    this.imageUrl,
    this.name,
    this.price,
    this.colors,
    this.sizes,
    this.favouriteItems,
    required this.productId,
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
  bool isLoading = false;

  int quantity = 1;

  Future<void> _placeOrder() async {
    setState(() => isLoading = true);

    final provider = Provider.of<CreateOrderProvider>(context, listen: false);

    List<Map<String, dynamic>> productList = [];

    if (widget.favouriteItems != null && widget.favouriteItems!.isNotEmpty) {
      for (var item in widget.favouriteItems!) {
        productList.add({
          "productId": item["productId"] ?? "",
          "quantity": item["quantity"] ?? 1,
          "selectedColor": item["colors"] ?? [],
          "selectedSize": item["sizes"] ?? [],
        });
      }
    } else {
      productList.add({
        "productId": widget.productId,
        "quantity": quantity,
        "selectedColor": widget.colors ?? [],
        "selectedSize": widget.sizes ?? [],
      });
    }

    await provider.placeOrder(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      additionalNote: _additionalNoteController.text.trim(),
      products: productList,
      shipmentCharges: 200,
    );

    setState(() => isLoading = false);

    if (provider.orderData != null && provider.orderData!.order != null) {
      Provider.of<FavouriteProvider>(
        context,
        listen: false,
      ).deleteAllFavourites();

      AppToast.success("Order placed successfully");

      Navigator.pop(context);
    } else {
      AppToast.error(provider.errorMessage ?? "Failed to place order");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ USERID login guard (same pattern)
    return AuthGate(child: _buildScaffold(context));
  }

  Widget _buildScaffold(BuildContext context) {
    final isFromFavourite =
        widget.favouriteItems != null && widget.favouriteItems!.isNotEmpty;

    double singlePrice = double.tryParse(widget.price ?? "0") ?? 0;
    double productTotal = isFromFavourite
        ? _calculateFavouriteTotal()
        : (singlePrice * quantity);
    double shipment = 200;
    double grandTotal = productTotal + shipment;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.appimagecolor,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: CustomButton(text: "Place Order", onTap: _placeOrder),
          ),
        ),
        body: Stack(
          children: [
            CustomBgContainer(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 30.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFromFavourite)
                        SizedBox(
                          height: 110.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.favouriteItems!.length,
                            itemBuilder: (context, index) {
                              final item = widget.favouriteItems![index];
                              return Container(
                                margin: EdgeInsets.only(right: 10.w),
                                padding: EdgeInsets.all(8.w),
                                width: 180.w,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.network(
                                        Global.imageUrl + item["imageUrl"],
                                        height: 60.h,
                                        width: 60.w,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["name"],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.sp,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "Rs: ${item["price"]}",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          if (item["colors"] != null &&
                                              item["colors"].isNotEmpty)
                                            Text(
                                              "Colors: ${item["colors"].join(', ')}",
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          if (item["sizes"] != null &&
                                              item["sizes"].isNotEmpty)
                                            Text(
                                              "Sizes: ${item["sizes"].join(', ')}",
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          Text(
                                            "Qty: ${item["quantity"]}",
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.network(
                                widget.imageUrl!,
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
                                    widget.name ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  Text(
                                    widget.price ?? "",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14.sp,
                                    ),
                                  ),

                                  // Show only if available (and no extra space)
                                  if (widget.colors != null &&
                                      widget.colors!.isNotEmpty)
                                    Text(
                                      "Colors: ${widget.colors!.join(', ')}",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  if (widget.sizes != null &&
                                      widget.sizes!.isNotEmpty)
                                    Text(
                                      "Sizes: ${widget.sizes!.join(', ')}",
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

                      if (!isFromFavourite)
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if (quantity > 1) {
                                  setState(() => quantity--);
                                }
                              },
                              child: Container(
                                height: 35.h,
                                width: 35.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: AppColor.primaryColor,
                                  ),
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
                                setState(() => quantity++);
                              },
                              child: Container(
                                height: 35.h,
                                width: 35.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                child: const Icon(Icons.add, size: 20),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 20.h),

                      Expanded(
                        child: Center(
                          child: CustomAppContainer(
                            width: double.infinity,
                            padding: EdgeInsets.all(24.w),
                            child: SingleChildScrollView(
                              child: Column(
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

                                  SizedBox(height: 20.h),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Price: Rs ${productTotal.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Shipment Charges: Rs ${shipment.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Grand Total: Rs ${grandTotal.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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

            /// FULL SCREEN LOADER
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: SpinKitThreeBounce(
                    color: AppColor.primaryColor,
                    size: 40.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateFavouriteTotal() {
    double total = 0.0;
    if (widget.favouriteItems != null) {
      for (var item in widget.favouriteItems!) {
        final price = double.tryParse(item["price"].toString()) ?? 0.0;
        final qty = int.tryParse(item["quantity"].toString()) ?? 1;
        total += price * qty;
      }
    }
    return total;
  }
}
