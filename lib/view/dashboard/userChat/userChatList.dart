// view/dashboard/userChat/userChatListScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/socketServices.dart';
import 'package:user_side/view/auth/AuthLoginGate.dart';
import 'package:user_side/view/dashboard/userChat/userChatScreen.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/chatThread_provider.dart';

class UserChatListScreen extends StatefulWidget {
  const UserChatListScreen({super.key});

  @override
  State<UserChatListScreen> createState() => _UserChatListScreenState();
}

class _UserChatListScreenState extends State<UserChatListScreen> {
  String? buyerId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // ✅ USERID based (AuthSession already init in main)
    buyerId = AuthSession.instance.userId ?? await LocalStorage.getUserId();

    if (buyerId != null && buyerId!.trim().isNotEmpty) {
      print("📩 Loading chat threads for buyer: $buyerId");
      await context.read<ChatThreadProvider>().fetchThreads(buyerId!);

      // ✅ Setup socket listeners for real-time updates
      _setupSocketListeners();
    } else {
      print("❌ No buyerId found");
    }
  }

  void _setupSocketListeners() {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) {
      print("⚠️ Socket not connected in chat list");
      return;
    }

    // ✅ Listen for new messages to update thread list
    socket.off("chat:message");
    socket.off("exchange:new");

    socket.on("chat:message", (data) {
      print("📩 Chat list received message");
      if (buyerId != null) {
        context.read<ChatThreadProvider>().fetchThreads(buyerId!);
      }
    });

    socket.on("exchange:new", (data) {
      print("📩 Chat list received exchange request");
      if (buyerId != null) {
        context.read<ChatThreadProvider>().fetchThreads(buyerId!);
      }
    });
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return "";
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return "Just now";
      } else if (difference.inHours < 1) {
        return "${difference.inMinutes}m ago";
      } else if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(date);
      } else if (difference.inDays == 1) {
        return "Yesterday";
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(date);
      } else {
        return DateFormat('dd/MM/yy').format(date);
      }
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Guard this whole screen (UserId based)
    return AuthGate(child: _buildScaffold(context));
  }

  Widget _buildScaffold(BuildContext context) {
    final provider = context.watch<ChatThreadProvider>();
    final threads = provider.threadListModel?.threads ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 1,
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: provider.loading
          ? Utils.loadingLottie()
          : threads.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                if (buyerId != null) {
                  await provider.fetchThreads(buyerId!);
                }
              },
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: threads.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1.h, indent: 80.w, color: Colors.black12),
                itemBuilder: (context, i) {
                  final thread = threads[i];
                  return _buildChatTile(
                    thread,
                  ).animate().fadeIn(delay: (i * 30).ms).slideX(begin: 0.1);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Utils.messageEmpty(size: 400),
          Text(
            "No conversations yet",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(thread) {
    final hasUnread = thread.unreadCount > 0;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColor.primaryColor.withOpacity(0.1),
            backgroundImage: thread.image != null
                ? NetworkImage(Global.imageUrl + thread.image!)
                : null,
            child: thread.image == null
                ? Icon(Icons.store, size: 28.sp, color: AppColor.primaryColor)
                : null,
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              thread.title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(thread.lastMessageTime),
            style: TextStyle(
              fontSize: 12.sp,
              color: hasUnread ? AppColor.primaryColor : Colors.black45,
              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (thread.isExchangeRequest) ...[
            Icon(Icons.swap_horiz, size: 14.sp, color: AppColor.primaryColor),
            SizedBox(width: 4.w),
          ],
          Expanded(
            child: Text(
              thread.lastMessage,
              style: TextStyle(
                fontSize: 13.sp,
                color: hasUnread ? Colors.black87 : Colors.black54,
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (hasUnread)
            Container(
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                "${thread.unreadCount}",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        print("📱 Opening chat: ${thread.threadId}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserChatScreen(
              threadId: thread.threadId,
              toType: thread.toType,
              toId: thread.toId,
              title: thread.title,
              sellerImage: thread.image,
            ),
          ),
        ).then((_) {
          // Refresh after returning
          if (buyerId != null) {
            context.read<ChatThreadProvider>().fetchThreads(buyerId!);
          }
        });
      },
    );
  }
}
