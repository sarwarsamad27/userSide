import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryAndProduct/productBelowCategory.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfile/widget/ContactAction.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfile/widget/PillInfo.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfile/widget/actionTile.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfile/widget/premiumCard.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/widgets/premiumSurface.dart';
import 'package:user_side/view/dashboard/userChat/userChatScreen.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/followUnFollow_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllCategoryProfileWise_provider.dart';
import 'package:user_side/widgets/customButton.dart';

class CompanyProfileScreen extends StatefulWidget {
  final String companyName;
  final String logoUrl;
  final String profileId;
  final String categoryId;
  final String description;
  final String phoneNumber;
  final String email;

  const CompanyProfileScreen({
    super.key,
    required this.companyName,
    required this.logoUrl,
    required this.profileId,
    required this.categoryId,
    required this.description,
    required this.phoneNumber,
    required this.email,
  });

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ Fetch categories
      final categoryProvider = Provider.of<GetAllCategoryProfileWiseProvider>(
        context,
        listen: false,
      );

      await categoryProvider.fetchCategories(widget.profileId);

      if (categoryProvider.data != null &&
          categoryProvider.data!.categories!.isNotEmpty) {
        categoryProvider.selectCategory(0);
      }

      // ✅ Fetch follow status
      final followProvider = Provider.of<FollowProvider>(
        context,
        listen: false,
      );
      followProvider.getFollowStatus(widget.profileId);
    });
  }

  @override
  void didUpdateWidget(covariant CompanyProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId) {
      final followProvider = Provider.of<FollowProvider>(
        context,
        listen: false,
      );
      followProvider.reset();
      followProvider.getFollowStatus(widget.profileId);
    }
  }

  void showCallOptions(BuildContext context, String phoneNumber) {
    final whatsappNumber = phoneNumber.startsWith("0")
        ? "+92${phoneNumber.substring(1)}"
        : phoneNumber;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Text(
                    "Contact via",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      size: 20.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              ActionTile(
                icon: Icons.phone,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                title: "Call",
                subtitle: whatsappNumber,
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: whatsappNumber);
                  try {
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  } catch (e) {
                    debugPrint("Error launching call: $e");
                  }
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 10.h),
              ActionTile(
                icon: Icons.phone_android_outlined,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF16A34A),
                title: "WhatsApp",
                subtitle: "Chat on WhatsApp",
                onTap: () async {
                  final uri = Uri.parse("https://wa.me/$whatsappNumber");
                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  } catch (e) {
                    debugPrint("Error launching WhatsApp: $e");
                  }
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────────────── Header (cover + avatar) ─────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 210.h,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/shookoo_image.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.10),
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: -48.h,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Avatar with ring
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            print("👆icon BUTTON TAPPED");
                          },
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.primaryColor.withOpacity(0.95),
                                  AppColor.primaryColor.withOpacity(0.35),
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 42.r,
                              backgroundColor: const Color(0xFFF3F4F6),
                              backgroundImage: NetworkImage(
                                Global.imageUrl + widget.logoUrl,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // ✅ FIXED Follow Button
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 58.h),

            // ───────────────── Main info card ─────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Consumer<FollowProvider>(
                builder: (context, followProvider, child) {
                  return PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.companyName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // ✅ FOLLOW BUTTON
                            // ✅ FOLLOW BUTTON (FIXED - reliable taps)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                // ✅ ensures tap works even if child is small / transparent
                                borderRadius: BorderRadius.circular(8.r),
                                onTap: followProvider.isLoading
                                    ? null
                                    : () async {
                                        await followProvider.toggleFollow(
                                          widget.profileId,
                                        );

                                        if (followProvider.errorMessage ==
                                            "You are not login") {
                                          if (!mounted) return;
                                          AppToast.show(
                                            "Please login to follow",
                                          );
                                        }
                                      },
                                child: Ink(
                                  height: 42.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: followProvider.isLoading
                                        ? AppColor.appimagecolor
                                        : (followProvider.isFollowing
                                              ? Colors.white
                                              : AppColor.primaryColor),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: followProvider.isFollowing
                                          ? AppColor.primaryColor
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Center(
                                    child: followProvider.isLoading
                                        ? SizedBox(
                                            height: 20.h,
                                            width: 20.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    followProvider.isFollowing
                                                        ? AppColor.primaryColor
                                                        : Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            followProvider.isFollowing
                                                ? "Following"
                                                : "Follow",
                                            style: TextStyle(
                                              color: followProvider.isFollowing
                                                  ? AppColor.primaryColor
                                                  : Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),

                        // ✅ Followers Count
                        Row(
                          children: [
                            PillInfo(
                              icon: Icons.people_alt_outlined,
                              text: followProvider.followersCount >= 1000
                                  ? "${(followProvider.followersCount / 1000).toStringAsFixed(1)}k Followers"
                                  : "${followProvider.followersCount} Followers",
                            ),
                            SizedBox(width: 10.w),
                            PillInfo(
                              icon: Icons.verified_outlined,
                              text: "Company",
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            color: const Color(0xFF4B5563),
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 14.h),
                        const DividerLine(),
                        SizedBox(height: 14.h),

                        // Contact actions
                        Row(
                          children: [
                            Expanded(
                              child: ContactAction(
                                icon: Icons.phone,
                                title: "Contact",
                                subtitle: "Call / WhatsApp",
                                iconBg: const Color(0xFFEFF6FF),
                                iconColor: const Color(0xFF2563EB),
                                onTap: () => showCallOptions(
                                  context,
                                  widget.phoneNumber,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ContactAction(
                                icon: Icons.chat_bubble_outline,
                                title: "Chat",
                                subtitle: "Chat with brand",
                                iconBg: const Color(0xFFECFDF5),
                                iconColor: const Color(0xFF16A34A),
                                onTap: () {
                                  if (!isLoggedIn) {
                                    AppToast.show("Login your account to chat");
                                  } else
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserChatScreen(
                                          threadId: "",
                                          toType: "profile",
                                          toId: widget.profileId,
                                          title: widget.companyName,
                                          sellerImage: widget.logoUrl,
                                        ),
                                      ),
                                    );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 18.h),

            // ───────────────── Categories ─────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SectionHeader(title: "Categories"),
            ),
            SizedBox(height: 10.h),

            SizedBox(
              height: 35.h,
              child: Consumer<GetAllCategoryProfileWiseProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: SpinKitThreeBounce(
                        color: AppColor.primaryColor,
                        size: 30.0,
                      ),
                    );
                  }
                  if (provider.data == null ||
                      provider.data!.categories!.isEmpty) {
                    return const Center(child: Text("No Categories Found"));
                  }

                  final categoriesData = provider.data!.categories!;
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: categoriesData.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (_, index) {
                      final isSelected = provider.selectedIndex == index;
                      final categoryName = categoriesData[index].name ?? "";

                      return InkWell(
                        onTap: () {
                          provider.selectCategory(index);
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColor.primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColor.primaryColor
                                  : const Color(0xFFE5E7EB),
                            ),
                            boxShadow: isSelected
                                ? const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 14,
                                      offset: Offset(0, 8),
                                    ),
                                  ]
                                : const [],
                          ),
                          child: Center(
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),

            // ───────────────── Products ─────────────────
            Consumer<GetAllCategoryProfileWiseProvider>(
              builder: (context, provider, child) {
                if (provider.data == null ||
                    provider.data!.categories!.isEmpty) {
                  return const Center(child: Text("No Products Found"));
                }
                final categoryId =
                    provider.data!.categories![provider.selectedIndex].sId ??
                    '';
                return ProductBelowCategory(
                  profileId: widget.profileId,
                  categoryId: categoryId,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
