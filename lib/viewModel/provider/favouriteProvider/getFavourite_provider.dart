import 'package:flutter/material.dart';
import 'package:user_side/models/favouriteModel/getFavouriteList_model.dart';
import 'package:user_side/models/favouriteModel/deleteFavourite_model.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/offline_queue.dart';
import 'package:user_side/viewModel/provider/connectivity_provider.dart';
import 'package:user_side/viewModel/repository/favouriteRepository/addToFavourite_repository.dart';
import 'package:user_side/viewModel/repository/favouriteRepository/deleteFavourite_repository.dart';
import 'package:user_side/viewModel/repository/favouriteRepository/getFavouriteList_repository.dart';

class FavouriteProvider extends ChangeNotifier {
  bool loading = false;
  FavouriteListModel? favouriteList;
  Map<int, int> quantityMap = {};

  final GetFavouriteListRepository repo = GetFavouriteListRepository();
  final DeleteFavouriteRepository deleteRepo = DeleteFavouriteRepository();
  final AddToFavouriteRepository addRepo = AddToFavouriteRepository();

  /// Fetch favourites — uses cached data when offline.
  Future<void> getFavourites() async {
    loading = true;
    notifyListeners();

    final userId = await LocalStorage.getUserId();
    favouriteList = await repo.getFavouriteList(userId ?? '');

    quantityMap = {};
    for (int i = 0; i < (favouriteList?.favourites?.length ?? 0); i++) {
      quantityMap[i] = 1;
    }

    loading = false;
    notifyListeners();
  }

  /// Toggle a product in/out of favourites.
  /// Offline → optimistic UI update + queue for sync when online.
  Future<bool> toggleFavourite({
    required String productId,
    required String userId,
    required List<String> selectedColors,
    required List<String> selectedSizes,
    required bool currentlyFavourited,
    required int index,
  }) async {
    if (!ConnectivityProvider.hasNetworkInterface) {
      // Optimistic: remove or add locally
      if (currentlyFavourited && index >= 0) {
        favouriteList?.favourites?.removeAt(index);
        quantityMap.remove(index);
      }
      notifyListeners();

      await OfflineQueue.enqueue(
        type: currentlyFavourited ? 'favourite_remove' : 'favourite_add',
        data: {
          'productId': productId,
          'userId': userId,
          'selectedColors': selectedColors,
          'selectedSizes': selectedSizes,
        },
      );
      return true;
    }

    if (currentlyFavourited) {
      return deleteFavourite(index);
    } else {
      try {
        final result = await addRepo.addToFavourite(
          productId: productId,
          userId: userId,
          selectedColors: selectedColors,
          selectedSizes: selectedSizes,
        );
        if (result.success == true) await getFavourites();
        return result.success ?? false;
      } catch (_) {
        return false;
      }
    }
  }

  bool isFavouriteQueueType(String? type) =>
      type == 'favourite_add' || type == 'favourite_remove';

  /// Submits one queued favourite add/remove. Returns true on success
  /// (removing it from the queue). Driven by SyncCoordinator on reconnect.
  Future<bool> syncOne(Map<String, dynamic> item) async {
    try {
      final data = item['data'] as Map<String, dynamic>;
      final userId = await LocalStorage.getUserId() ?? '';
      if (item['type'] == 'favourite_add') {
        await addRepo.addToFavourite(
          productId: data['productId'] as String,
          userId: userId,
          selectedColors: List<String>.from(data['selectedColors'] ?? []),
          selectedSizes: List<String>.from(data['selectedSizes'] ?? []),
        );
      } else {
        await deleteRepo.deleteFavourite(userId, data['productId'] as String);
      }
      await OfflineQueue.remove(item['id'] as String);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteAllFavourites() async {
    try {
      final userId = await LocalStorage.getUserId();
      if (favouriteList?.favourites == null) return;
      final len = favouriteList!.favourites!.length;
      for (int i = 0; i < len; i++) {
        final item = favouriteList!.favourites![0];
        await deleteRepo.deleteFavourite(userId ?? '', item.product?.sId ?? '');
        favouriteList!.favourites!.removeAt(0);
      }
      quantityMap.clear();
      notifyListeners();
    } catch (e) {
      debugPrint("Delete all favourites error: $e");
    }
  }

  Future<void> deleteOrderedFavourites(List<String> productIds) async {
    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) return;
      for (final pid in productIds) {
        await deleteRepo.deleteFavourite(userId, pid);
      }
      await getFavourites();
    } catch (e) {
      debugPrint("Delete ordered favourites error: $e");
    }
  }

  Future<bool> deleteFavourite(int index) async {
    try {
      final item = favouriteList!.favourites![index];
      final userId = await LocalStorage.getUserId();
      final DeleteFavouriteProductModel res = await deleteRepo.deleteFavourite(
        userId ?? '',
        item.product?.sId ?? '',
      );
      if (res.success == true) {
        favouriteList!.favourites!.removeAt(index);
        quantityMap.remove(index);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Delete favourite error: $e");
      return false;
    }
  }

  void increaseQuantity(int index) {
    quantityMap[index] = (quantityMap[index] ?? 1) + 1;
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if ((quantityMap[index] ?? 1) > 1) {
      quantityMap[index] = (quantityMap[index] ?? 1) - 1;
      notifyListeners();
    }
  }

  double getTotal() {
    double total = 0;
    for (int i = 0; i < (favouriteList?.favourites?.length ?? 0); i++) {
      final item = favouriteList!.favourites![i];
      final qty = quantityMap[i] ?? 1;
      total += (item.product?.afterDiscountPrice?.toDouble() ?? 0) * qty;
    }
    return total;
  }

  int getQuantity(int index) => quantityMap[index] ?? 1;
}
