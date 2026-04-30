import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/socketServices.dart';

class BuyerAdminMessagesScreen extends StatefulWidget {
  const BuyerAdminMessagesScreen({super.key});

  @override
  State<BuyerAdminMessagesScreen> createState() => _BuyerAdminMessagesScreenState();
}

class _BuyerAdminMessagesScreenState extends State<BuyerAdminMessagesScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _listenSocket();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    setState(() => _loading = true);
    try {
      final token = await LocalStorage.getToken();
      final buyerId = AuthSession.instance.userId ?? '';
      final res = await http.get(
        Uri.parse('${Global.BuyerGetAdminMessages}?buyerId=$buyerId'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _messages
            ..clear()
            ..addAll((data['messages'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('fetchAdminMessages error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _listenSocket() {
    final socket = SocketService().socket;
    socket?.off('admin:broadcast');
    socket?.on('admin:broadcast', (data) {
      if (!mounted) return;
      final d = Map<String, dynamic>.from(data);
      if (d['toType'] == 'all_buyers') {
        setState(() => _messages.add(d));
        _scrollToBottom();
      }
    });
    socket?.off('admin:message');
    socket?.on('admin:message', (data) {
      if (!mounted) return;
      setState(() => _messages.add(Map<String, dynamic>.from(data)));
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                'assets/images/shookoo_image.png',
                width: 32.w,
                height: 32.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(LucideIcons.shieldCheck, color: Colors.white, size: 22.sp),
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SHOOKOO Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                Text('Official Support', style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
              ],
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AppColor.primaryColor,
                  onRefresh: _fetchMessages,
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _bubble(_messages[i]),
                  ),
                ),
    );
  }

  Widget _bubble(Map<String, dynamic> msg) {
    final text = msg['message']?.toString() ?? '';
    final isBroadcast = msg['toType'] == 'all_buyers';
    final time = msg['createdAt'] != null
        ? DateFormat('hh:mm a, dd MMM').format(DateTime.tryParse(msg['createdAt'].toString()) ?? DateTime.now())
        : '';

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(
              'assets/images/shookoo_image.png',
              width: 36.w,
              height: 36.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(LucideIcons.shieldCheck, size: 18.sp, color: AppColor.primaryColor),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SHOOKOO Admin',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColor.primaryColor),
                    ),
                    if (isBroadcast) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text('📢 Announcement', style: TextStyle(fontSize: 9.sp, color: AppColor.primaryColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14.r),
                      bottomLeft: Radius.circular(14.r),
                      bottomRight: Radius.circular(14.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(text, style: TextStyle(fontSize: 13.sp, color: Colors.black87)),
                ),
                SizedBox(height: 3.h),
                Text(time, style: TextStyle(fontSize: 10.sp, color: Colors.grey[400])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(
                'assets/images/shookoo_image.png',
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(LucideIcons.shieldCheck, size: 64.sp, color: Colors.grey[300]),
              ),
            ),
            SizedBox(height: 16.h),
            Text('No messages from Admin yet', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
            SizedBox(height: 6.h),
            Text('Announcements & replies will appear here', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
          ],
        ),
      );
}
