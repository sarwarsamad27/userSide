import 'package:flutter/material.dart';
import 'package:user_side/resources/offline_queue.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/getFavourite_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/createOrder_provider.dart';

/// Drives the whole offline-queue sync (favourites + COD orders) as one
/// sequential, awaited run so screens never see a half-synced state.
///
/// Screens watch [isSyncing]/[percent] for a progress indicator and
/// [syncVersion] to know when to refresh their own data after a run finishes.
class SyncCoordinator with ChangeNotifier {
  final FavouriteProvider favouriteProvider;
  final CreateOrderProvider orderProvider;

  SyncCoordinator({
    required this.favouriteProvider,
    required this.orderProvider,
  });

  bool isSyncing = false;
  int total = 0;
  int completed = 0;
  int syncVersion = 0;

  double get percent => total == 0 ? 1.0 : completed / total;

  Future<void> syncAll() async {
    if (isSyncing) return;

    final items = await OfflineQueue.getAll();
    if (items.isEmpty) return;

    isSyncing = true;
    total = items.length;
    completed = 0;
    notifyListeners();

    final favItems = items
        .where((e) => favouriteProvider.isFavouriteQueueType(e['type']))
        .toList();
    for (final item in favItems) {
      await favouriteProvider.syncOne(item);
      completed++;
      notifyListeners();
    }
    if (favItems.isNotEmpty) await favouriteProvider.getFavourites();

    final orderItems = items.where((e) => e['type'] == 'cod_order').toList();
    for (final item in orderItems) {
      await orderProvider.syncOne(item);
      completed++;
      notifyListeners();
    }

    isSyncing = false;
    syncVersion++;
    notifyListeners();
  }
}
