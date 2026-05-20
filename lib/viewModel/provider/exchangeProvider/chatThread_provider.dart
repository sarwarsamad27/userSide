import 'package:flutter/material.dart';
import 'package:user_side/models/chatModel/chatThreadModel.dart';
import 'package:user_side/viewModel/repository/chatRepository/chatThread_repository.dart';

class ChatThreadProvider extends ChangeNotifier {
  final ChatThreadRepository repository = ChatThreadRepository();

  bool loading = false;
  ChatThreadListModel? threadListModel;

  Future<void> fetchThreads(String buyerId) async {
    // loading = true;
    // notifyListeners();

    try {
      threadListModel = await repository.getChatThreads(buyerId);
      print("✅ Threads loaded: ${threadListModel?.threads.length}");
    } catch (e) {
      print("❌ Error loading threads: $e");
      threadListModel = ChatThreadListModel(
        success: false,
        message: "Error: $e",
        threads: [],
      );
    }

    loading = false;
    notifyListeners();
  }

  /// ✅ NAVBAR BADGE COUNT (TOTAL UNREAD)
  int get unreadTotal {
    final threads = threadListModel?.threads ?? <ChatThreadModel>[];
    int total = 0;

    for (final t in threads) {
      // ✅ YAHAN FIELD NAME MATCH KARO
      // agar aapke model me unread ka field different hai:
      // t.unreadMessages / t.unread / t.unreadMessageCount etc
      final c = (t.unreadCount ?? 0);

      total += c;
    }

    return total;
  }

  void addOrUpdateThread(ChatThreadModel thread) {
    if (threadListModel == null) return;

    final existingIndex = threadListModel!.threads.indexWhere(
      (t) => t.threadId == thread.threadId,
    );

    if (existingIndex != -1) {
      threadListModel!.threads[existingIndex] = thread;
    } else {
      threadListModel!.threads.insert(0, thread);
    }

    notifyListeners();
  }

  // In-memory update — no API call
  void onNewMessage({
    required String threadId,
    required String lastMessage,
    required String lastMessageTime,
    bool incrementUnread = true,
    bool isExchangeRequest = false,
  }) {
    final list = threadListModel?.threads;
    if (list == null) return;

    final idx = list.indexWhere((t) => t.threadId == threadId);
    if (idx == -1) return;

    final old = list[idx];
    final updated = ChatThreadModel(
      threadId: old.threadId,
      toType: old.toType,
      toId: old.toId,
      title: old.title,
      image: old.image,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: incrementUnread ? old.unreadCount + 1 : old.unreadCount,
      isExchangeRequest: isExchangeRequest,
    );

    list.removeAt(idx);
    list.insert(0, updated);
    notifyListeners();
  }

  void markThreadRead(String threadId) {
    final list = threadListModel?.threads;
    if (list == null) return;
    final idx = list.indexWhere((t) => t.threadId == threadId);
    if (idx == -1 || list[idx].unreadCount == 0) return;
    final t = list[idx];
    list[idx] = ChatThreadModel(
      threadId: t.threadId,
      toType: t.toType,
      toId: t.toId,
      title: t.title,
      image: t.image,
      lastMessage: t.lastMessage,
      lastMessageTime: t.lastMessageTime,
      unreadCount: 0,
      isExchangeRequest: t.isExchangeRequest,
    );
    notifyListeners();
  }
}
