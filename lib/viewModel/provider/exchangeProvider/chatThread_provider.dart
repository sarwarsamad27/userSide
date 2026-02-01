import 'package:flutter/material.dart';
import 'package:user_side/models/chatModel/chatThreadModel.dart';
import 'package:user_side/viewModel/repository/chatRepository/chatThread_repository.dart';

class ChatThreadProvider extends ChangeNotifier {
  final ChatThreadRepository repository = ChatThreadRepository();

  bool loading = false;
  ChatThreadListModel? threadListModel;

  Future<void> fetchThreads(String buyerId) async {
    loading = true;
    notifyListeners();

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

    final existingIndex =
        threadListModel!.threads.indexWhere((t) => t.threadId == thread.threadId);

    if (existingIndex != -1) {
      threadListModel!.threads[existingIndex] = thread;
    } else {
      threadListModel!.threads.insert(0, thread);
    }

    notifyListeners();
  }
}
