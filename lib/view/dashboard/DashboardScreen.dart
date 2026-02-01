import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/resources/local_storage.dart';

import 'package:user_side/view/dashboard/favourite/favourite_screen.dart';
import 'package:user_side/view/dashboard/homeDashboard/homeScreen.dart';
import 'package:user_side/view/dashboard/products/productScreen.dart';
import 'package:user_side/view/dashboard/profile/profileScreen.dart';
import 'package:user_side/view/dashboard/userChat/userChatList.dart';

import 'package:user_side/viewModel/provider/exchangeProvider/chatThread_provider.dart';

class HomeNavBarScreen extends StatefulWidget {
  final String? productId;
  const HomeNavBarScreen({super.key, this.productId});

  @override
  State<HomeNavBarScreen> createState() => _HomeNavBarScreenState();
}

class _HomeNavBarScreenState extends State<HomeNavBarScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPress;

  final screens = const [
    HomeScreen(), // 0
    ProductScreen(), // 1
    UserChatListScreen(), // 2
    FavouriteScreen(), // 3
    Profilescreen(), // 4
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatThreadProvider()..fetchThreadsFromStorage(),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;

              final now = DateTime.now();
              if (_lastBackPress == null ||
                  now.difference(_lastBackPress!) >
                      const Duration(seconds: 2)) {
                _lastBackPress = now;
                AppToast.success("Press back again to exit the app");
                return;
              }

              final shouldExit = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text("Exit App"),
                  content: const Text("Do you want to exit the application?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );

              if (shouldExit == true) {
                SystemNavigator.pop();
              }
            },
            child: Scaffold(
              extendBody: true,
              backgroundColor: const Color(0xFFF9FAFB),
              body: screens[_currentIndex],
              bottomNavigationBar: _PremiumUserNavBar(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ✅ Helper extension to fetch buyerId automatically
extension _ThreadProviderExt on ChatThreadProvider {
  Future<void> fetchThreadsFromStorage() async {
    final buyerId = await LocalStorage.getUserId();
    if (buyerId == null || buyerId.isEmpty) return;
    await fetchThreads(buyerId);
  }
}

class _PremiumUserNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumUserNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = context.select<ChatThreadProvider, int>(
      (p) => p.unreadTotal,
    );

    final barHeight = 76.h;

    return SizedBox(
      height: barHeight + 26.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ✅ Base premium pill bar (equal widths)
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                _slot(
                  child: _NavItem(
                    icon: LucideIcons.home,
                    label: "Home",
                    selected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                _slot(
                  child: _NavItem(
                    icon: LucideIcons.package,
                    label: "Products",
                    selected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),

                // ✅ equal center gap slot
                _slot(child: const SizedBox.shrink()),

                _slot(
                  child: _NavItem(
                    icon: LucideIcons.shoppingCart,
                    label: "Favourite",
                    selected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ),
                _slot(
                  child: _NavItem(
                    icon: LucideIcons.user,
                    label: "Profile",
                    selected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Floating messages button (with badge)
          Positioned(
            top: -6.h,
            child: _CenterMessagesButton(
              selected: currentIndex == 2,
              unreadCount: unread,
              onTap: () => onTap(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot({required Widget child}) => Expanded(child: child);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColor.primaryColor.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22.sp, // ✅ fixed size (no jump)
                color: selected ? AppColor.primaryColor : Colors.grey,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp, // ✅ fixed size (no jump)
                  color: selected ? AppColor.primaryColor : Colors.grey,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterMessagesButton extends StatelessWidget {
  final bool selected;
  final int unreadCount;
  final VoidCallback onTap;

  const _CenterMessagesButton({
    required this.selected,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 66.w,
        height: 66.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withOpacity(0.85),
                  ]
                : [Colors.white, Colors.white],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: selected ? Colors.transparent : Colors.black12,
            width: 1.2,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              LucideIcons.messageCircle,
              size: 26.sp,
              color: selected ? Colors.white : AppColor.primaryColor,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -2.w,
                top: -2.w,
                child: _Badge(count: unreadCount),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? "99+" : "$count";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
