import 'package:flutter/material.dart';
import 'package:user_side/models/notification_services/notificationModel.dart';
import 'package:user_side/viewModel/repository/notificationRepository/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository repo = NotificationRepository();

  bool isLoading = false;
  BuyerNotificationResponse? data;
  List<BuyerNotificationItem> items = [];
  int unreadCount = 0;

  bool _hasFetched = false;
  bool _isFetching = false;

  bool get hasFetched => _hasFetched;

  Future<void> fetch({bool showLoader = true, bool force = false}) async {
    // Prevent duplicate hits
    if (_isFetching) return;

    // Prevent repeated hits if already fetched once
    if (_hasFetched && !force) return;

    _isFetching = true;

    if (showLoader) {
      isLoading = true;
      notifyListeners();
    }

    try {
      final res = await repo.fetchNotifications();
      data = res;
      items = res.notifications ?? [];
      unreadCount = res.unreadCount ?? 0;

      _hasFetched = true;
    } finally {
      isLoading = false;
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    // Force true => pull-to-refresh pe hit ho
    await fetch(showLoader: false, force: true);
  }

  Future<void> markAsRead(String notificationId) async {
    final ok = await repo.markRead(notificationId);
    if (!ok) return;

    final idx = items.indexWhere((n) => n.id == notificationId);
    if (idx != -1 && (items[idx].isRead != true)) {
      items[idx].isRead = true;
      if (unreadCount > 0) unreadCount -= 1;
      notifyListeners();
    }
  }
}
