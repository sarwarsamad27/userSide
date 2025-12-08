import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // For call/whatsapp/email
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

      // 🔹 Always select first category after fetch
      if (provider.data != null && provider.data!.categories!.isNotEmpty) {
        provider.selectCategory(0); // first category by default
        setState(() => selectedCategory = 0); // update local state
      }
    });
  }

  /// Show Bottom Sheet to choose Call or WhatsApp
  void showCallOptions(BuildContext context, String phoneNumber) {
    final whatsappNumber = phoneNumber.startsWith("0")
        ? "+92${phoneNumber.substring(1)}"
        : phoneNumber;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Contact via",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blue),
              title: Text("Call"),
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
            ListTile(
              leading: Icon(Icons.phone_android_outlined, color: Colors.green),
              title: Text("WhatsApp"),
              onTap: () async {
                final uri = Uri.parse("https://wa.me/$whatsappNumber");
                try {
                  if (await canLaunchUrl(uri))
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  debugPrint("Error launching WhatsApp: $e");
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Launch Email safely
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
      backgroundColor: AppColor.appimagecolor,
      body: CustomBgContainer(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/shookoo_image.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -45,
                    left: 20.w,
                    child: CircleAvatar(
                      radius: 45.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 43.r,
                        backgroundImage: NetworkImage(widget.logoUrl),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 55.h),

              /// Company Name + Follow
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.companyName,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing
                            ? Colors.white
                            : AppColor.primaryColor,
                        elevation: 0,
                        side: isFollowing
                            ? BorderSide(color: AppColor.primaryColor)
                            : BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isFollowing = !isFollowing;
                          followerCount += isFollowing ? 1 : -1;
                        });
                      },
                      icon: Icon(
                        isFollowing ? Icons.favorite : Icons.favorite_border,
                        color: isFollowing
                            ? AppColor.primaryColor
                            : Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        isFollowing ? "Following" : "Follow",
                        style: TextStyle(
                          color: isFollowing
                              ? AppColor.primaryColor
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "${(followerCount / 1000).toStringAsFixed(1)}k Followers",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 15.h),

              /// Contact / Info Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    contactTile(
                      Icons.phone,
                      "Cont",
                      Colors.blue,
                      () => showCallOptions(context, widget.phoneNumber),
                    ),
                    contactTile(
                      Icons.email,
                      "Email",
                      Colors.red,
                      () => launchEmail(widget.email),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              /// Categories
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              SizedBox(
                height: 45.h,
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

                        return GestureDetector(
                          onTap: () {
                            provider.selectCategory(index);
                            setState(() => selectedCategory = index);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColor.primaryColor
                                  : AppColor.primaryColor.withOpacity(.3),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Center(
                              child: Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
              SizedBox(height: 20.h),

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

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

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
