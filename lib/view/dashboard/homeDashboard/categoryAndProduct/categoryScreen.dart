import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryAndProduct/productBelowCategory.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllCategoryProfileWise_provider.dart';

class Categoryscreen extends StatefulWidget {
  final String profileId;
  final String? categoryId;

  const Categoryscreen({Key? key, required this.profileId, this.categoryId})
    : super(key: key);

  @override
  State<Categoryscreen> createState() => _CategoryscreenState();
}

class _CategoryscreenState extends State<Categoryscreen> {
  @override
  void initState() {
    super.initState();

    // 🔹 Fix: fetchCategories after first frame to avoid build-phase setState error
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<GetAllCategoryProfileWiseProvider>(
        context,
        listen: false,
      );

      await provider.fetchCategories(widget.profileId);

      if (widget.categoryId != null) {
        final index = provider.data!.categories!.indexWhere(
          (c) => c.sId == widget.categoryId,
        );

        if (index != -1) {
          provider.selectCategory(index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetAllCategoryProfileWiseProvider>(context);

    if (provider.isLoading) {
      return Scaffold(body: Utils.shoppingLoadingLottie());
    }

    if (provider.data == null ||
        provider.data!.categories == null ||
        provider.data!.categories!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Utils.notFound(size: 300), Text("No Categories Found")],
          ),
        ),
      );
    }

    final categories = provider.data!.categories!;
    final selectedIndex = provider.selectedIndex;

    // 🚀 EXTRA SAFE CHECK – ensure selectedIndex is valid
    if (selectedIndex < 0 || selectedIndex >= categories.length) {
      return const Scaffold(
        body: Center(child: Text("Invalid Category Selected")),
      );
    }

    final media = MediaQuery.of(context).size;
    final halfHeight = media.height * 0.5;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: halfHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    Global.imageUrl + (categories[selectedIndex].image ?? ""),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),

                  /// CATEGORY TABS
                  Positioned(
                    bottom: 10.h,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 30.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final item = categories[index];
                          final isSelected = selectedIndex == index;

                          return GestureDetector(
                            onTap: () {
                              provider.selectCategory(index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(horizontal: 8.w),
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Center(
                                child: Text(
                                  item.name ?? "",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white.withOpacity(0.8),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// PRODUCT GRID
            ProductBelowCategory(
              profileId: categories[selectedIndex].profileId ?? '',
              categoryId: categories[selectedIndex].sId ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
