import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/viewModel/provider/productProvider/activeCategoryChips_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getAllProduct_provider.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customsearchbar.dart';
import 'package:provider/provider.dart';

class SearchbarCategorylist extends StatefulWidget {
  final Function(String) onCategorySelected;
  final String? initialCategory;

  const SearchbarCategorylist({
    super.key,
    required this.onCategorySelected,
    this.initialCategory,
  });

  @override
  State<SearchbarCategorylist> createState() => _SearchbarCategorylistState();
}

class _SearchbarCategorylistState extends State<SearchbarCategorylist> {
  late final ValueNotifier<String> _selectedNotifier;

  @override
  void initState() {
    super.initState();
    _selectedNotifier = ValueNotifier(widget.initialCategory ?? 'All');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActiveCategoryChipsProvider>().fetch();
      // If an initial category was supplied, trigger the callback immediately
      if (widget.initialCategory != null && widget.initialCategory != 'All') {
        widget.onCategorySelected(widget.initialCategory!);
      }
    });
  }

  @override
  void dispose() {
    _selectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allProductProvider =
        Provider.of<GetAllProductProvider>(context, listen: false);

    return Container(
      color: AppColor.appimagecolor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16).w,
            child: CustomSearchBar(
              onChanged: (value) => allProductProvider.searchProducts(value),
            ),
          ),
          SizedBox(height: 14.h),

          // ── Dynamic category chips ───────────────────────────────────────
          Consumer<ActiveCategoryChipsProvider>(
            builder: (context, chipsProvider, _) {
              // Build full list: "All" always first, then sorted active chips
              final dynamicChips = ['All', ...chipsProvider.chips];

              return SizedBox(
                height: 34.h,
                child: ValueListenableBuilder<String>(
                  valueListenable: _selectedNotifier,
                  builder: (context, selected, _) {
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 12).w,
                      scrollDirection: Axis.horizontal,
                      itemCount: dynamicChips.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final label = dynamicChips[index];
                        final isSelected = selected == label;

                        return GestureDetector(
                          onTap: () {
                            _selectedNotifier.value = label;
                            widget.onCategorySelected(label);
                          },
                          child: CustomAppContainer(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 5.h,
                            ),
                            color: isSelected
                                ? AppColor.whiteColor
                                : AppColor.primaryColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20.r),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? AppColor.primaryColor
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
