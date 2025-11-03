import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:user_side/resources/appColor.dart';
// import 'package:user_side/view/companySide/dashboard/dashboardScreen/dashboardScreen.dart';
// import 'package:user_side/view/companySide/dashboard/orderScreen/orderScreen.dart';
// import 'package:user_side/view/companySide/dashboard/productScreen/productCategory/productCategoryScreen.dart';
// import 'package:user_side/view/companySide/dashboard/profileScreen.dart/profileScreen.dart';
import 'package:user_side/view/dashboard/favourite/favourite_screen.dart';
import 'package:user_side/view/dashboard/homeDashboard/homeScreen.dart';
import 'package:user_side/view/dashboard/products/productScreen.dart';
import 'package:user_side/view/dashboard/profile/profileScreen.dart';

class HomeNavBarScreen extends StatefulWidget {
  const HomeNavBarScreen({super.key});

  @override
  State<HomeNavBarScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<HomeNavBarScreen> {
  int _currentIndex = 0;

  final screens = [
    const HomeScreen(),
    const ProductScreen(),
    const FavouiteScreen(),
    const Profilescreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: screens[_currentIndex],

          /// 🔹 Animated Bottom Navbar
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                navItem(LucideIcons.home, "Home", 0),
                navItem(LucideIcons.package, "Products", 1),
                navItem(LucideIcons.shoppingCart, "Favourite", 2),
                navItem(LucideIcons.user, "Profile", 3),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔸 Custom Navbar Item
  Widget navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isSelected ? AppColor.primaryColor : Colors.grey,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected ? AppColor.primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
