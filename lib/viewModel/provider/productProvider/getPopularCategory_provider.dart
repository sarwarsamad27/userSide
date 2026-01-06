import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:user_side/models/ProductAndCategoryModel/popularCategory_model.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/popularCategory_repository.dart';

class PopularCategoryProvider extends ChangeNotifier {
  final GetPopularCategoryRepository _repository =
      GetPopularCategoryRepository();

  PopularCategoryModel? categoryData;
  bool loading = false;

  bool hasFetchedAtLeastOnce = false;
  List<Categories> allCategories = [];

  bool isFetchedOnce = false;
  Future<void>? _inFlightRequest;

  Future<void> fetchPopularCategories({bool force = false}) async {
    if (_inFlightRequest != null) return _inFlightRequest!;

    // if already fetched AND list still has data -> don't hit again unless force
    if (!force && isFetchedOnce && allCategories.isNotEmpty) return;

    _inFlightRequest = _fetchInternal(force: force);
    await _inFlightRequest;
    _inFlightRequest = null;
  }

  Future<void> _fetchInternal({required bool force}) async {
    if (loading) return;

    loading = true;
    notifyListeners();

    try {
      final response = await _repository.getPopularCategory();

      log("controller response"+response.toString());
      hasFetchedAtLeastOnce = true;


      if (response.success == true) {

        allCategories = response.categories ?? [];


        categoryData = PopularCategoryModel(
          success: response.success,
          page: response.page,
          limit: response.limit,
          totalCategories: response.totalCategories,
          totalPages: response.totalPages,
          categories: allCategories,
        );

        isFetchedOnce = true;
      }
    } catch (_) {
      hasFetchedAtLeastOnce = true;
    }

    loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    isFetchedOnce = false;
    await fetchPopularCategories(force: true);
  }
}
