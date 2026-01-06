import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryAndProduct/productBelowCategory.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfile/widget/ContactAction.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfile/widget/PillInfo.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfile/widget/actionTile.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/companyProfile/widget/premiumCard.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/widgets/premiumSurface.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllCategoryProfileWise_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';

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
  int selectedCategory = 0;
  bool isFollowing = false;
  int followerCount = 1250;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<GetAllCategoryProfileWiseProvider>(
        context,
        listen: false,
      );

      await provider.fetchCategories(widget.profileId);

      if (provider.data != null && provider.data!.categories!.isNotEmpty) {
        provider.selectCategory(0);
        setState(() => selectedCategory = 0);
      }
    });
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

  void launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (e) {
      debugPrint("Error launching email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    // subtle overlay to make header premium
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
                            backgroundImage: NetworkImage(widget.logoUrl),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Follow button aligned nicely in header
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            height: 42.h,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing
                                    ? Colors.white
                                    : AppColor.primaryColor,
                                elevation: 0,
                                side: isFollowing
                                    ? BorderSide(color: AppColor.primaryColor)
                                    : BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                              ),
                              onPressed: () {
                                setState(() {
                                  isFollowing = !isFollowing;
                                  followerCount += isFollowing ? 1 : -1;
                                });
                              },
                              icon: Icon(
                                isFollowing
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFollowing
                                    ? AppColor.primaryColor
                                    : Colors.white,
                                size: 18.sp,
                              ),
                              label: Text(
                                isFollowing ? "Following" : "Follow",
                                style: TextStyle(
                                  color: isFollowing
                                      ? AppColor.primaryColor
                                      : Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 62.h),

            // ───────────────── Main info card ─────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                    SizedBox(height: 6.h),

                    Row(
                      children: [
                        PillInfo(
                          icon: Icons.people_alt_outlined,
                          text:
                              "${(followerCount / 1000).toStringAsFixed(1)}k Followers",
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

                    // Contact actions (same logic)
                    Row(
                      children: [
                        Expanded(
                          child: ContactAction(
                            icon: Icons.phone,
                            title: "Contact",
                            subtitle: "Call / WhatsApp",
                            iconBg: const Color(0xFFEFF6FF),
                            iconColor: const Color(0xFF2563EB),
                            onTap: () =>
                                showCallOptions(context, widget.phoneNumber),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ContactAction(
                            icon: Icons.email_outlined,
                            title: "Email",
                            subtitle: widget.email,
                            iconBg: const Color(0xFFFFF1F2),
                            iconColor: const Color(0xFFE11D48),
                            onTap: () => launchEmail(widget.email),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 18.h),

            // ───────────────── Categories header ─────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SectionHeader(title: "Categories"),
            ),
            SizedBox(height: 10.h),

            // ───────────────── Categories chips (premium) ─────────────────
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
                          setState(() => selectedCategory = index);
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

