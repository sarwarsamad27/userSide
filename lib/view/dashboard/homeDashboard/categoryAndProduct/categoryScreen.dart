import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryAndProduct/productBelowCategory.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllCategoryProfileWise_provider.dart';

class Categoryscreen extends StatefulWidget {
  final String profileId;

  const Categoryscreen({Key? key, required this.profileId}) : super(key: key);

  @override
  State<Categoryscreen> createState() => _CategoryscreenState();
}

class _CategoryscreenState extends State<Categoryscreen> {
  final List<Map<String, String>> products = const [
    {
      'name': 'Running Shoes',
      'price': '3,499',
      'image':
          'https://thumbs.dreamstime.com/b/beautiful-rain-forest-ang-ka-nature-trail-doi-inthanon-national-park-thailand-36703721.jpg',
    },
    {
      'name': 'Casual Sneakers',
      'price': '2,199',
      'image':
          'https://cdn.pixabay.com/photo/2025/04/28/19/59/female-model-9565629_640.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<GetAllCategoryProfileWiseProvider>(
      context,
      listen: false,
    ).fetchCategories(widget.profileId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetAllCategoryProfileWiseProvider>(context);
    final media = MediaQuery.of(context).size;
    final halfHeight = media.height * 0.5;

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.data == null ||
                provider.data!.categories == null ||
                provider.data!.categories!.isEmpty
          ? const Center(child: Text("No Categories Found"))
          : Column(
              children: [
                SizedBox(
                  height: halfHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        provider
                                .data!
                                .categories![provider.selectedIndex]
                                .image ??
                            "",
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                          ),
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

                      Positioned(
                        left: 16.w,
                        right: 16.w,
                        bottom: 80.h,
                        child: Text(
                          provider
                                  .data!
                                  .categories![provider.selectedIndex]
                                  .name ??
                              "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      /// CATEGORY TABS (Horizontal Scroll)
                      Positioned(
                        bottom: 10.h,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 30.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: provider.data!.categories!.length,
                            itemBuilder: (context, index) {
                              final item = provider.data!.categories![index];
                              final isSelected =
                                  provider.selectedIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  provider.selectCategory(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                  ),
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

                /// PRODUCT GRID (UNCHANGED)
                ///
                ProductBelowCategory(
                  profileId:
                      provider
                          .data!
                          .categories![provider.selectedIndex]
                          .profileId ??
                      '',
                  categoryId:
                      provider.data!.categories![provider.selectedIndex].sId ??
                      '',
                ),
              ],
            ),
    );
  }
}
