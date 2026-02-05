import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customsearchbar.dart';
import 'package:provider/provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getAllProduct_provider.dart';

class SearchbarCategorylist extends StatefulWidget {
  final Function(String) onCategorySelected;

  const SearchbarCategorylist({super.key, required this.onCategorySelected});

  @override
  State<SearchbarCategorylist> createState() => _SearchbarCategorylistState();
}

class _SearchbarCategorylistState extends State<SearchbarCategorylist> {
  final List<String> categories = [
    "All",
    "Clothes",
    "Shoes",
    "Bags",
    "Accessories",
    "Beauty",
  ];

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier(0);

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetAllProductProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSearchBar(
          onChanged: (value) {
            provider.searchProducts(value);
          },
        ),

        SizedBox(height: 10.h),

        /// CATEGORY LIST
        SizedBox(
          height: 30.h,
          child: ValueListenableBuilder<int>(
            valueListenable: _selectedIndexNotifier,
            builder: (context, selectedIndex, _) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      _selectedIndexNotifier.value = index;

                      widget.onCategorySelected(categories[index]);
                    },
                    child: CustomAppContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 5.h,
                      ),
                      color: isSelected
                          ? AppColor.primaryColor
                          : AppColor.primaryColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Center(
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black,
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
