import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryAndProduct/categoryScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/notificationScreen/notificationIcon.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/notificationScreen/notification_screen.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllProfile_provider.dart';
import 'package:user_side/viewModel/provider/notificationProvider/notification_provider.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/widgets/customsearchbar.dart';
import 'package:user_side/widgets/productContainer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetAllProfileProvider>(
        context,
        listen: false,
      ).fetchProfiles();
      Provider.of<NotificationProvider>(context, listen: false).fetch();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      final provider = context.read<GetAllProfileProvider>();
      if (provider.hasMore && !provider.isLoading && !provider.isLoadingMore) {
        provider.fetchProfiles(loadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetAllProfileProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 50.h),
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
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                  ),

                  SizedBox(width: 12.w),

                  NotificationIconButton(
                    unreadCount: notifProvider.unreadCount,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
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
                    ? Utils.loadingLottie()
                    : provider.productData == null ||
                          provider.productData!.profiles == null ||
                          provider.productData!.profiles!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Utils.notFound(size: 300.sp),
                            Text("No Profiles Found"),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await provider.refreshProfiles(); // 🔥 REFRESH API
                          provider.applySearch(""); // 🔥 RESET search
                        },
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(bottom: 24.h),
                          physics:
                              const AlwaysScrollableScrollPhysics(), // IMPORTANT
                          itemCount:
                              provider.filteredProfiles.length +
                              (provider.isLoadingMore ? 2 : 0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 230.h,
                                crossAxisSpacing: 14.w,
                                mainAxisSpacing: 6.h,
                              ),
                          itemBuilder: (context, index) {
                            if (index >= provider.filteredProfiles.length) {
                              return const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              );
                            }

                            final item = provider.filteredProfiles[index];

                            return CategoryTile(
                                  name: item.name ?? "",
                                  image: item.image ?? "",
                                  averageDiscount: item.averageDiscount,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Categoryscreen(
                                          profileId: item.sId!,
                                        ),
                                      ),
                                    );
                                  },
                                )
                                .animate()
                                .fadeIn(delay: (index * 50).ms)
                                .scale(begin: const Offset(0.9, 0.9));
                          },
                        ),
                      ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
