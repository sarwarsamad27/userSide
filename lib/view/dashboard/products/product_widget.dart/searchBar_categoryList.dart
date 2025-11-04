import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customsearchbar.dart';

class SearchbarCategorylist extends StatelessWidget {
   SearchbarCategorylist({super.key});
       final List<String> categories = [
      "All",
      "Clothes",
      "Shoes",
      "Bags",
      "Accessories",
      "Beauty",
    ];

    final ValueNotifier<int> selectedCategoryIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomSearchBar(),
                      SizedBox(height: 10.h),
                      SizedBox(
                        height: 35.h,
                        child: ValueListenableBuilder<int>(
                          valueListenable: selectedCategoryIndex,
                          builder: (context, selectedIndex, _) {
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, __) => SizedBox(width: 8.w),
                              itemBuilder: (context, index) {
                                final isSelected = selectedIndex == index;

                                return GestureDetector(
                                  onTap: () {
                                    selectedCategoryIndex.value = index;
                                  },
                                  child: CustomAppContainer(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 6.h,
                                    ),
                                    color: isSelected
                                        ? AppColor.primaryColor
                                        : AppColor.primaryColor.withOpacity(
                                            0.4,
                                          ),
                                    borderRadius: BorderRadius.circular(20.r),
                                    child: Center(
                                      child: Text(
                                        categories[index],
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
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
                    ],
                  );
  }
}