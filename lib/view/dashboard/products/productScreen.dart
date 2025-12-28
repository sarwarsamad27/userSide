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
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!_initialFetchDone) _fetchAll();
    });
  }

  Future<void> _fetchAll({bool refresh = false}) async {
    if (_initialFetchDone && !refresh) return;

    final allProductProvider = Provider.of<GetAllProductProvider>(
      context,
      listen: false,
    );
    final popularProductProvider = Provider.of<PopularProductProvider>(
      context,
      listen: false,
    );
    final popularCategoryProvider = Provider.of<PopularCategoryProvider>(
      context,
      listen: false,
    );

    if (refresh) {
      allProductProvider.allProducts.clear();
      allProductProvider.filteredProducts.clear();
      popularProductProvider.popularProducts = null;
      popularCategoryProvider.allCategories.clear();

      allProductProvider.isFetchedOnce = false;
      popularProductProvider.isFetchedOnce = false;
      popularCategoryProvider.isFetchedOnce = false;
    }

    await Future.wait([
      allProductProvider.fetchProducts(),
      popularProductProvider.fetchPopularProducts(),
      popularCategoryProvider.fetchPopularCategories(),
    ]);

    _initialFetchDone = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _fetchAll(refresh: true),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StickyHeaderDelegate(
                    minHeight: 130.h,
                    maxHeight: 130.h,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 5.h,
                      ),
                      child: SearchbarCategorylist(
                        onCategorySelected: (category) {
                          setState(() {
                            selectedCategory = category;
                          });

                          if (category != "All") {
                            final catProvider =
                                Provider.of<GetCategoryWiseProductProvider>(
                                  context,
                                  listen: false,
                                );
                            catProvider.fetchCategoryProducts(
                              category,
                              refresh: true,
                            );
                          }

                          final allProvider =
                              Provider.of<GetAllProductProvider>(
                                context,
                                listen: false,
                              );

                          if (category == "All") {
                            allProvider.clearFilter();
                            allProvider.fetchProducts();
                          } else {
                            allProvider.filterByCategory(category);
                          }
                        },
                      ),
                    ),
                  ),
                ),

                if (selectedCategory == "All") ...[
                  PopularProductAndCategory(),
                  AllProducts(),
                ],

                if (selectedCategory != "All")
                  SliverToBoxAdapter(
                    child: CategoryWiseProductsWidget(
                      category: selectedCategory,
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
