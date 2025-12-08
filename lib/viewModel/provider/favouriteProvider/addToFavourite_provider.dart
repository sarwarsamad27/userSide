import 'package:flutter/material.dart';
import 'package:user_side/models/favouriteModel/addToFavourite_model.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/repository/favouriteRepository/addToFavourite_repository.dart';

class AddToFavouriteProvider extends ChangeNotifier {
  bool loading = false;
  AddToFavouriteModel? favouriteResponse;

  final AddToFavouriteRepository repository = AddToFavouriteRepository();

  Future<void> addToFavourite({
    required String productId,
    List<String>? selectedSizes,
    List<String>? selectedColors,
  }) async {
    loading = true;
    notifyListeners();

    String? buyerId = await LocalStorage.getUserId();

    favouriteResponse = await repository.addToFavourite(
      userId: buyerId ?? '',
      productId: productId,
      selectedColors: selectedColors ?? [],
      selectedSizes: selectedSizes ?? [],
    );

    loading = false;
    notifyListeners();
  }
}
