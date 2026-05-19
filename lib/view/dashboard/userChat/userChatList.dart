// view/dashboard/userChat/userChatListScreen.dart

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

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
import 'package:user_side/view/dashboard/userChat/admin_messages_screen.dart';
import 'package:user_side/view/dashboard/userChat/userChatScreen.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/chatThread_provider.dart';

class UserChatListScreen extends StatefulWidget {
  const UserChatListScreen({super.key});

  @override
  State<UserChatListScreen> createState() => _UserChatListScreenState();
}

class _UserChatListScreenState extends State<UserChatListScreen> {
  String? buyerId;

  // ── Admin message state ─────────────────────────────────────────────────
  int _adminUnread = 0;
  String _adminLastMsg = 'Official support & announcements';
  DateTime? _adminLastTime;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    buyerId = AuthSession.instance.userId ?? await LocalStorage.getUserId();

    if (buyerId != null && buyerId!.trim().isNotEmpty) {
      log('📩 Loading chat threads for buyer: $buyerId');
      await context.read<ChatThreadProvider>().fetchThreads(buyerId!);
      _setupSocketListeners();
      _fetchAdminMessageState();
    }
  }

  // Fetch admin messages to populate last-message + unread count
  Future<void> _fetchAdminMessageState() async {
    try {
      final token = await LocalStorage.getToken();
      final uid = buyerId ?? '';
      final res = await http.get(
        Uri.parse('${Global.BuyerGetAdminMessages}?buyerId=$uid'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );
      if (res.statusCode == 200 && mounted) {
        final msgs = (jsonDecode(res.body)['messages'] as List? ?? []);
        final fromAdmin = msgs.where((m) => m['fromType'] == 'admin').toList();
        if (fromAdmin.isNotEmpty) {
          final last = fromAdmin.last;
          // Count only unread messages (same logic as seller side)
          final unreadCount = fromAdmin.where((m) {
            if (m['toType'] == 'buyer') return m['isRead'] == false;
            if (m['toType'] == 'all_buyers') {
              final readBy = (m['readBy'] as List? ?? []);
              return uid.isNotEmpty &&
                  !readBy.any((r) => r.toString() == uid.toString());
            }
            return false;
          }).length;
          setState(() {
            _adminLastMsg = last['message']?.toString() ?? _adminLastMsg;
            _adminLastTime = DateTime.tryParse(
              last['createdAt']?.toString() ?? '',
            );
            _adminUnread = unreadCount;
          });
        }
      }
    } catch (_) {}
  }

  void _setupSocketListeners() async {
    // Must use buyerId auth — backend sets role:"buyer" only from buyerId
    // Using token auth can assign wrong role → fromType:"seller" on buyer msgs
    final uid = buyerId ?? AuthSession.instance.userId ?? await LocalStorage.getUserId();
    if (uid == null || uid.isEmpty || !mounted) return;

    final socket = await SocketService().ensureConnected(
      baseUrl: Global.imageUrl,
      auth: {'buyerId': uid},
    );
    if (socket == null || !mounted) return;

    // Clear first to avoid duplicate handlers
    socket.off("chat:message");
    socket.off("exchange:new");
    socket.off("admin:message");
    socket.off("admin:broadcast");

    // In-memory update — no API call needed
    socket.on("chat:message", (data) {
      if (!mounted || data is! Map) return;
      final tId = data["threadId"]?.toString();
      final text = (data["text"] ?? "").toString();
      final ts = (data["timestamp"] ?? data["createdAt"] ??
              DateTime.now().toIso8601String())
          .toString();
      final fromType = data["fromType"]?.toString();
      if (tId == null) return;

      final provider = context.read<ChatThreadProvider>();
      final known =
          provider.threadListModel?.threads.any((t) => t.threadId == tId) ??
              false;

      if (known) {
        // buyer's own sent messages (fromType=="buyer") don't add unread
        provider.onNewMessage(
          threadId: tId,
          lastMessage: text,
          lastMessageTime: ts,
          incrementUnread: fromType != "buyer",
        );
      } else {
        // New thread: fetch once to discover it
        if (buyerId != null) provider.fetchThreads(buyerId!);
      }
    });

    socket.on("exchange:new", (data) {
      if (!mounted || data is! Map) return;
      final tId = data["threadId"]?.toString();
      if (tId == null) return;
      context.read<ChatThreadProvider>().onNewMessage(
        threadId: tId,
        lastMessage: "📦 New exchange request",
        lastMessageTime: DateTime.now().toIso8601String(),
        incrementUnread: true,
        isExchangeRequest: true,
      );
    });

    socket.on("admin:message", (data) {
      if (!mounted) return;
      final msg = (data is Map) ? data : {};
      setState(() {
        _adminUnread++;
        _adminLastMsg = msg['message']?.toString() ?? _adminLastMsg;
        _adminLastTime = DateTime.now();
      });
    });

    socket.on("admin:broadcast", (data) {
      if (!mounted) return;
      final msg = (data is Map) ? data : {};
      if (msg['toType'] == 'all_buyers') {
        setState(() {
          _adminUnread++;
          _adminLastMsg = msg['message']?.toString() ?? _adminLastMsg;
          _adminLastTime = DateTime.now();
        });
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
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: provider.loading
          ? Utils.loadingLottie()
          : RefreshIndicator(
              onRefresh: () async {
                if (buyerId != null) await provider.fetchThreads(buyerId!);
              },
              child: ListView.separated(
                padding: EdgeInsets.zero,
                // +1 for pinned admin tile at index 0
                itemCount: threads.length + 1,
                separatorBuilder: (_, __) =>
                    Divider(height: 1.h, indent: 80.w, color: Colors.black12),
                itemBuilder: (context, i) {
                  if (i == 0) return _buildAdminTile(context);
                  final thread = threads[i - 1];
                  return _buildChatTile(
                    thread,
                  ).animate().fadeIn(delay: (i * 30).ms).slideX(begin: 0.1);
                },
              ),
            ),
    );
  }

  Widget _buildAdminTile(BuildContext context) {
    final hasUnread = _adminUnread > 0;
    final timeStr = _adminLastTime != null
        ? _formatTime(_adminLastTime.toString())
        : '';

    return InkWell(
      onTap: () {
        setState(() => _adminUnread = 0);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BuyerAdminMessagesScreen()),
        );
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Image.asset(
                'assets/images/shookoo_image.png',
                width: 56.r,
                height: 56.r,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColor.primaryColor.withValues(
                    alpha: 0.15,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: AppColor.primaryColor,
                    size: 26.sp,
                  ),
                ),
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 14.w,
                  height: 14.w,
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
                'SHOOKOO Admin',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (timeStr.isNotEmpty)
              Text(
                timeStr,
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
            Expanded(
              child: Text(
                _adminLastMsg,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: hasUnread ? Colors.black87 : Colors.black54,
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasUnread)
              Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$_adminUnread',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(thread) {
    final hasUnread = thread.unreadCount > 0;
    log(Global.getImageUrl(thread.image));
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColor.primaryColor.withValues(alpha: 0.1),
            child: ClipOval(
              child: thread.image != null && thread.image!.isNotEmpty
                  ? Image.network(
                      Global.getImageUrl(thread.image),
                      width: 56.r,
                      height: 56.r,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.store,
                        size: 28.sp,
                        color: AppColor.primaryColor,
                      ),
                    )
                  : Icon(
                      Icons.store,
                      size: 28.sp,
                      color: AppColor.primaryColor,
                    ),
            ),
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
        // Clear unread badge immediately in-memory
        context.read<ChatThreadProvider>().markThreadRead(thread.threadId);

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
          // Re-register socket listeners — chat screen may have removed them
          if (mounted) _setupSocketListeners();
        });
      },
    );
  }
}
