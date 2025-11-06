import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/widgets/customBgContainer.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Help Center",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.black,
          ),
        ),
      ),

      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 💬 Header Message
                  Text(
                    "How can we help you?",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Get in touch with our support team or browse FAQs to quickly resolve your issues.",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 20.h),

                  /// 📞 Contact Options
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.phone, color: AppColor.primaryColor),
                      title: const Text("Call Us"),
                      subtitle: const Text("+91 98765 43210"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Call logic or linking here
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.email_outlined,
                        color: AppColor.primaryColor,
                      ),
                      title: const Text("Email Support"),
                      subtitle: const Text("support@nichee.com"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Open mail app
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColor.primaryColor,
                      ),
                      title: const Text("Chat with Us"),
                      subtitle: const Text("Available 9 AM - 8 PM"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Chat support screen or link
                      },
                    ),
                  ),
                  SizedBox(height: 25.h),

                  /// ❓FAQ Section
                  Text(
                    "Frequently Asked Questions",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  ExpansionTile(
                    title: const Text("How can I track my order?"),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          "Go to 'Order History' and tap on the order to view its current status and tracking details.",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("Can I cancel my order?"),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          "Orders can be canceled before they are shipped. Go to your order details and select 'Cancel Order'.",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("What payment methods do you accept?"),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          "We accept Credit/Debit Cards, UPI, Net Banking, and major Wallets.",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("How do I return a product?"),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          "To return an item, go to 'My Orders', select the product, and choose 'Return'. Follow the instructions provided.",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
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
    );
  }
}
