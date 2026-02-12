import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/allProducts.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/categoryWiseProduct.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/popularProduct&Category.dart';
import 'package:user_side/view/dashboard/products/product_widget.dart/searchBar_categoryList.dart';
import 'package:user_side/viewModel/provider/productProvider/categoryWiseProduct_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getAllProduct_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularCategory_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularProduct_provider.dart';
import 'package:user_side/widgets/customStickyHeader.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _initialFetchDone = false;
  final ValueNotifier<String> _selectedCategoryNotifier = ValueNotifier("All");

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_initialFetchDone) {
        await _fetchAll();
        _initialFetchDone = true;
      }
    });
  }

  @override
  void dispose() {
    _selectedCategoryNotifier.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    final allProductProvider = context.read<GetAllProductProvider>();
    final popularProductProvider = context.read<PopularProductProvider>();
    final popularCategoryProvider = context.read<PopularCategoryProvider>();

    // ✅ these providers should self-skip if already fetched once
    await Future.wait([
      allProductProvider.fetchProducts(),
      popularProductProvider.fetchPopularProducts(),
      popularCategoryProvider.fetchPopularCategories(),
    ]);
  }

  Future<void> _refreshAll() async {
    final allProductProvider = context.read<GetAllProductProvider>();
    final popularProductProvider = context.read<PopularProductProvider>();
    final popularCategoryProvider = context.read<PopularCategoryProvider>();

    // ✅ refresh = force API hit
    allProductProvider.isFetchedOnce = false;
    popularProductProvider.isFetchedOnce = false;

    await Future.wait([
      allProductProvider.fetchProducts(),
      popularProductProvider.fetchPopularProducts(),
      popularCategoryProvider.refresh(), // ✅ force refresh
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ValueListenableBuilder<String>(
            valueListenable: _selectedCategoryNotifier,
            builder: (context, selectedCategory, _) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyHeaderDelegate(
                      minHeight: 170.h,
                      maxHeight: 170.h,
                      child: SearchbarCategorylist(
                        onCategorySelected: (category) {
                          _selectedCategoryNotifier.value = category;

                          final allProvider = context
                              .read<GetAllProductProvider>();

                          if (category == "All") {
                            // ✅ only reset filter; DO NOT call fetch again
                            allProvider.clearFilter();
                            return;
                          }

                          allProvider.filterByCategory(category);

                          final catProvider = context
                              .read<GetCategoryWiseProductProvider>();
                          catProvider.fetchCategoryProducts(
                            category,
                            refresh: true,
                          );
                        },
                      ),
                    ),
                  ),

                  if (selectedCategory == "All") ...[
                    const PopularProductAndCategory(),
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 90),
                      sliver: const AllProducts(),
                    ),
                  ],
                  if (selectedCategory != "All")
                    SliverToBoxAdapter(
                      child: CategoryWiseProductsWidget(
                        category: selectedCategory,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
