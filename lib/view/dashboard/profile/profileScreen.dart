import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/view/auth/loginView.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/view/dashboard/profile/helpCenter.dart';
import 'package:user_side/view/dashboard/profile/offer.dart';
import 'package:user_side/view/dashboard/profile/order/orderHistory.dart';
import 'package:user_side/view/dashboard/profile/setting.dart';
import 'package:user_side/view/dashboard/profile/termAndCondition.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/recommendedProduct_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/productCard.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final deviceId = await LocalStorage.getOrCreateDeviceId();

    if (!mounted) return;

    Provider.of<RecommendationProvider>(
      context,
      listen: false,
    ).fetchRecommendations(deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.appimagecolor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColor.primaryColor.withOpacity(.3),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.black, size: 26),
          ),
          SizedBox(width: 10.w),
        ],
      ),

      body: CustomBgContainer(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              SizedBox(height: 15.h),

              Text(
                "Recommended For You",
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),

              Consumer<RecommendationProvider>(
                builder: (context, provider, _) {
                  if (provider.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.products.isEmpty) {
                    return const Text(
                      "No recommendations yet",
                      style: TextStyle(color: Colors.black),
                    );
                  }

                  return SizedBox(
                    height: 240.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.products.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final product = provider.products[index];

                        return SizedBox(
                          width: 180.w,
                          child: ProductCard(
                            name: product.name,

                            price: product.afterDiscountPrice.toString(),
                            imageUrl: product.images.isNotEmpty
                                ? product.images.first
                                : "",
                            description: product.description,

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    productId: product.id,
                                    categoryId: product.category.id,
                                    profileId: product.profile.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              /// 🔹 Quick Options
              Text(
                "Explore More",
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      optionTile(
                        context,
                        Icons.history,
                        "Order History",
                        Colors.pinkAccent,
                        OrderHistoryScreen(),
                      ),
                      optionTile(
                        context,
                        Icons.local_offer,
                        "Offers",
                        Colors.orangeAccent,
                        OffersScreen(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      optionTile(
                        context,
                        Icons.card_giftcard,
                        "Term & Condition",
                        Colors.teal,
                        TermsConditionScreen(),
                      ),
                      optionTile(
                        context,
                        Icons.support_agent,
                        "Help Center",
                        Colors.blue,
                        HelpCenterScreen(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  CustomButton(
                    text: "Log Out",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text(
                            "Are you sure you want to log out?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Clear saved token & userId
                                await LocalStorage.clearAll();

                                // Close popup
                                Navigator.pop(context);

                                // Navigate to login screen and clear history
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text("Logout"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 100.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget optionTile(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: CustomAppContainer(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        width: 170.w,
        height: 60.h,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            SizedBox(width: 4.w),
            FittedBox(
              child: Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
