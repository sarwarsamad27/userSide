import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryAndProduct/categoryScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/notificationScreen/notificationIcon.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/notificationScreen/notification_screen.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllProfile_provider.dart';
import 'package:user_side/viewModel/provider/notificationProvider/notification_provider.dart';
import 'package:user_side/widgets/customsearchbar.dart';
import 'package:user_side/widgets/productContainer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetAllProfileProvider>(
        context,
        listen: false,
      ).fetchProfiles();
       Provider.of<NotificationProvider>(context, listen: false).fetch();
    });
  }
  

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetAllProfileProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomSearchBar(
                        hintText: "Search brands...",
                        onChanged: (value) {
                          provider.applySearch(value);
                        },
                      ),
                    ),

                    SizedBox(width: 12.w),

              

NotificationIconButton(
  unreadCount: notifProvider.unreadCount,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    ).then((_) {
      // screen se wapis aate hi count refresh
      notifProvider.fetch(showLoader: false);
    });
  },
),

                  ],
                ),

                SizedBox(height: 16.h),

                Expanded(
                  child: provider.isLoading
                      ? Center(
                          child: SpinKitThreeBounce(
                            color: AppColor.primaryColor,
                            size: 30.0,
                          ),
                        )
                      : provider.productData == null ||
                            provider.productData!.profiles == null ||
                            provider.productData!.profiles!.isEmpty
                      ? const Center(child: Text("No Profiles Found"))
                      : RefreshIndicator(
                          onRefresh: () async {
                            await provider.refreshProfiles(); // 🔥 REFRESH API
                            provider.applySearch(""); // 🔥 RESET search
                          },
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            physics:
                                const AlwaysScrollableScrollPhysics(), // IMPORTANT
                            itemCount: provider.filteredProfiles.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: 230.h,
                                  crossAxisSpacing: 14.w,
                                  mainAxisSpacing: 6.h,
                                ),
                            itemBuilder: (context, index) {
                              final item = provider.filteredProfiles[index];

                              return CategoryTile(
                                name: item.name ?? "",
                                image: item.image ?? "",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Categoryscreen(profileId: item.sId!),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
