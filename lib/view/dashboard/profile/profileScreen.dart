import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/productCard.dart';

class Profilescreen extends StatelessWidget {
  const Profilescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            // 🧑‍🎨 Emoji Avatar
            CircleAvatar(
              radius: 20.r,
              backgroundColor: Colors.amber.shade200,
              child: const Text("😊", style: TextStyle(fontSize: 20)),
            ),
            SizedBox(width: 12.w),
            Text(
              "Hi, D!",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),

      body: CustomBgContainer(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 💰 Wallet Section
              CustomAppContainer(
                padding: EdgeInsets.all(16.w),

                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.wallet, color: Colors.orange),
                        SizedBox(width: 10.w),
                        Text(
                          "My Wallet",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "\$245.00",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              Container(
                height: 140.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Center(
                    child: Text(
                      "🛍️ Shop 30% OFF\nExclusive Deals for You!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 25.h),

              /// 🕒 Recently Viewed
              Text(
                "Recently Viewed",
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 210.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return ProductCard(
                      name: 'Product ${index + 1}',
                      price: '',
                      imageUrl: 'https://picsum.photos/200/300?random=$index',
                    );
                  },
                ),
              ),

              SizedBox(height: 25.h),

              /// 🔹 Quick Options
              Text(
                "Explore More",
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),

              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12.w,
                runSpacing: 12.h,
                children: [
                  optionTile(Icons.favorite, "Wishlist", Colors.pinkAccent),
                  optionTile(Icons.local_offer, "Offers", Colors.orangeAccent),
                  optionTile(Icons.card_giftcard, "Rewards", Colors.teal),
                  optionTile(Icons.support_agent, "Help Center", Colors.blue),
                  optionTile(Icons.settings, "Settings", Colors.grey),
                  optionTile(Icons.logout, "Logout", Colors.redAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget optionTile(IconData icon, String title, Color color) {
    return CustomAppContainer(
      width: 160.w,
      height: 60.h,

      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
