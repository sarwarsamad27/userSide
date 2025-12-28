import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryAndProduct/productBelowCategory.dart';
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

              _ActionTile(
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
              _ActionTile(
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
              child: _PremiumCard(
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
                        _PillInfo(
                          icon: Icons.people_alt_outlined,
                          text:
                              "${(followerCount / 1000).toStringAsFixed(1)}k Followers",
                        ),
                        SizedBox(width: 10.w),
                        _PillInfo(
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
                    const _DividerLine(),
                    SizedBox(height: 14.h),

                    // Contact actions (same logic)
                    Row(
                      children: [
                        Expanded(
                          child: _ContactAction(
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
                          child: _ContactAction(
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
              child: _SectionHeader(title: "Categories"),
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

            // ───────────────── Products list (unchanged call) ─────────────────
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

  // kept for compatibility (not used in new UI)
  Widget contactTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 70.w,
        height: 70.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 5.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Premium UI helpers (design only) ─────────────────────────

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE9EDF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: const Color(0xFFE5E7EB),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF111827),
          ),
        ),
        const Spacer(),
        Container(
          width: 42.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _PillInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PillInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.green),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ContactAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Icon(icon, color: iconColor, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Icon(icon, color: iconColor, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
