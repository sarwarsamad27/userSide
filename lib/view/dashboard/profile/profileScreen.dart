import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/view/auth/loginView.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/view/dashboard/profile/helpCenter.dart';
import 'package:user_side/view/dashboard/profile/offer.dart';
import 'package:user_side/view/dashboard/profile/order/orderHistory.dart';
import 'package:user_side/view/dashboard/profile/setting.dart';
import 'package:user_side/view/dashboard/profile/termAndCondition.dart';
import 'package:user_side/view/dashboard/profile/widgets/optionTile.dart';
import 'package:user_side/view/dashboard/profile/widgets/premiumOfferCard.dart';
import 'package:user_side/viewModel/provider/authProvider/signInWithGoogle_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/recommendedProduct_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/productCard.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  // --- Premium Offers Carousel (Circular/Infinite) ---
  late final PageController _offerPageController;
  Timer? _offerTimer;

  static const int _kLoopBase = 1000; // start in middle for "infinite"
  int _pageIndex = _kLoopBase;
  final ValueNotifier<int> _activeIndexNotifier = ValueNotifier(0);

  // Auto-slide config (increased)
  final Duration _autoSlideDuration = const Duration(seconds: 4);
  final Duration _slideAnimationDuration = const Duration(milliseconds: 650);

  final List<OfferCardData> _offers = const [
    OfferCardData(
      emoji: "🛍️",
      title: "Shop 30% OFF",
      subtitle: "Exclusive Deals for You!",
      badge: "LIMITED",
      icon: Icons.local_offer_outlined,
    ),
    OfferCardData(
      emoji: "⚡",
      title: "Flash Sale",
      subtitle: "New drops every day",
      badge: "HOT",
      icon: Icons.bolt_outlined,
    ),
    OfferCardData(
      emoji: "🎁",
      title: "Member Perks",
      subtitle: "Extra savings on bundles",
      badge: "PREMIUM",
      icon: Icons.card_giftcard_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _offerPageController = PageController(
      viewportFraction: 0.90,
      initialPage: _pageIndex,
    );

    // Update notifier slightly to init
    _activeIndexNotifier.value = _mapToOfferIndex(_pageIndex);

    _loadRecommendations();
    _startAutoOffers();
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    _offerPageController.dispose();
    _activeIndexNotifier.dispose();
    super.dispose();
  }

  int _mapToOfferIndex(int page) {
    if (_offers.isEmpty) return 0;
    final m = page % _offers.length;
    return m < 0 ? m + _offers.length : m;
  }

  void _startAutoOffers() {
    _offerTimer?.cancel();
    _offerTimer = Timer.periodic(_autoSlideDuration, (_) {
      if (!mounted) return;
      if (!_offerPageController.hasClients) return;
      if (_offers.isEmpty) return;

      _pageIndex++; // Local var, doesn't need setState if controller animates

      _offerPageController.animateToPage(
        _pageIndex,
        duration: _slideAnimationDuration,
        curve: Curves.easeInOutCubic,
      );
    });
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
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;
    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
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
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            SizedBox(width: 12.w),
            Text(
              "Hi, D!",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // ✅ Premium Offer Cards (Circular + Auto change)
              SizedBox(
                height: 160.h,
                child: ValueListenableBuilder<int>(
                  valueListenable: _activeIndexNotifier,
                  builder: (context, activeIndex, _) {
                    return PageView.builder(
                      controller: _offerPageController,
                      itemCount: 1000000, // large for infinite illusion
                      onPageChanged: (page) {
                        _pageIndex = page;
                        _activeIndexNotifier.value = _mapToOfferIndex(page);
                      },
                      itemBuilder: (context, page) {
                        final offerIndex = _mapToOfferIndex(page);
                        final data = _offers[offerIndex];

                        final bool isActive = offerIndex == activeIndex;

                        return AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          scale: isActive ? 1.0 : 0.94,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 6.h,
                            ),
                            child: PremiumOfferCard(
                              data: data,
                              isActive: isActive,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 10.h),

              // Dots Indicator (premium)
              ValueListenableBuilder<int>(
                valueListenable: _activeIndexNotifier,
                builder: (context, activeIndex, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_offers.length, (i) {
                      final bool active = i == activeIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        height: 7.h,
                        width: active ? 22.w : 7.w,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColor.primaryColor
                              : Colors.black.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      );
                    }),
                  );
                },
              ),

              SizedBox(height: 15.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  "Recommended For You",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Consumer<RecommendationProvider>(
                  builder: (context, provider, _) {
                    if (provider.loading) {
                      return Utils.loadingLottie(size: 100);
                    }

                    if (provider.products.isEmpty) {
                      return Column(
                        children: [
                          Utils.notFound(),
                          const Text(
                            "No recommendations yet",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      );
                    }

                    return SizedBox(
                      height: 260.h,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
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
                                  averageRating: product.averageRating, // ✅
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
                              )
                              .animate()
                              .fadeIn(delay: (index * 50).ms)
                              .slideX(begin: 0.1);
                        },
                      ),
                    );
                  },
                ),
              ),

              /// 🔹 Quick Options
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  "Explore More",
                  style: TextStyle(
                    fontSize: 17.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    if (isLoggedIn)
                      CustomButton(
                        text: "Log Out",
                        onTap: () async {
                          final provider = Provider.of<GoogleLoginProvider>(
                            context,
                            listen: false,
                          );
                          await provider.confirmLogout(context);
                        },
                      )
                    else
                      CustomButton(
                        text: "Login your account",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 20.h),
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

                    SizedBox(height: 90.h),
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

class OfferCardData {
  final String emoji;
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;

  const OfferCardData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
  });
}
