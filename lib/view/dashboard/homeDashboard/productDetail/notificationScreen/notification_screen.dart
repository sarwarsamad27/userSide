import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/auth/AuthLoginGate.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/view/dashboard/userChat/userChatScreen.dart';
import 'package:user_side/viewModel/provider/notificationProvider/notification_provider.dart';
import 'package:user_side/widgets/customBgContainer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<NotificationProvider>(context, listen: false);
      if (!p.hasFetched) {
        p.fetch();
      }
    });
  }

  // ✅ DEDUPE helper: removes duplicates from provider.items
  List<dynamic> _dedupeNotifications(List<dynamic> items) {
    final seen = <String>{};
    final unique = <dynamic>[];

    for (final n in items) {
      // try read data map for better unique key
      Map<String, dynamic> dataMap = <String, dynamic>{};
      final dynamic rawData = n.data;

      if (rawData is Map) {
        dataMap = rawData.map((k, v) => MapEntry(k.toString(), v));
      } else if (rawData is String && rawData.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawData);
          if (decoded is Map) {
            dataMap = decoded.map((k, v) => MapEntry(k.toString(), v));
          }
        } catch (_) {
          dataMap = <String, dynamic>{};
        }
      }

      final type = (n.type ?? "").toString();
      final id = (n.id ?? "").toString(); // prefer DB id if available

      // fallback composite key (covers NEW_PRODUCT duplicates)
      final productId = (dataMap["productId"] ?? "").toString();
      final profileId = (dataMap["profileId"] ?? "").toString();
      final categoryId = (dataMap["categoryId"] ?? "").toString();
      final title = (n.title ?? "").toString();
      final createdAt = (n.createdAt ?? "").toString();

      final key = id.isNotEmpty
          ? "id:$id"
          : "k:$type|$productId|$profileId|$categoryId|$title|$createdAt";

      if (seen.add(key)) {
        unique.add(n);
      }
    }

    return unique;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ USERID login guard (same pattern)
    return AuthGate(child: _buildScaffold(context));
  }

  Widget _buildScaffold(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    // ✅ Use deduped list for UI
    final dedupedItems = _dedupeNotifications(provider.items);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.appimagecolor,
        surfaceTintColor: Colors.white,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: AppColor.textPrimaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          if (provider.unreadCount > 0)
            Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.successColor,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: AppColor.successColor.withOpacity(0.18),
                    ),
                  ),
                  child: Text(
                    "${provider.unreadCount} unread",
                    style: TextStyle(
                      color: AppColor.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: CustomBgContainer(
        child: provider.isLoading
            ? const _NotifLoading()
            : dedupedItems.isEmpty
            ? const _EmptyNotif()
            : RefreshIndicator(
                onRefresh: provider.refresh,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  itemCount: dedupedItems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, i) {
                    final n = dedupedItems[i];
                    final isRead = n.isRead == true;

                    return _NotifTile(
                      title: n.title ?? "",
                      body: n.body ?? "",
                      image: n.image,
                      accentColorHex: n.accentColor,
                      isRead: isRead,
                      createdAt: n.createdAt,
                      onTap: () async {
                        // 1) mark as read
                        if (!isRead && n.id != null) {
                          await provider.markAsRead(n.id!);
                        }

                        // 2) routing
                        final type = (n.type ?? "").toString();

                        Map<String, dynamic> dataMap = <String, dynamic>{};
                        final dynamic rawData = n.data;

                        if (rawData == null) {
                          dataMap = <String, dynamic>{};
                        } else if (rawData is Map) {
                          dataMap = rawData.map(
                            (key, value) => MapEntry(key.toString(), value),
                          );
                        } else if (rawData is String && rawData.isNotEmpty) {
                          try {
                            final decoded = jsonDecode(rawData);
                            if (decoded is Map) {
                              dataMap = decoded.map(
                                (key, value) => MapEntry(key.toString(), value),
                              );
                            }
                          } catch (_) {
                            dataMap = <String, dynamic>{};
                          }
                        }

                        // 🔹 Handle NEW_PRODUCT type
                        if (type == "NEW_PRODUCT") {
                          final profileId = (dataMap["profileId"] ?? "")
                              .toString();
                          final categoryId = (dataMap["categoryId"] ?? "")
                              .toString();
                          final productId = (dataMap["productId"] ?? "")
                              .toString();

                          if (profileId.isNotEmpty &&
                              categoryId.isNotEmpty &&
                              productId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  profileId: profileId,
                                  categoryId: categoryId,
                                  productId: productId,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Product detail info missing in notification.",
                                ),
                              ),
                            );
                          }
                        }
                        // 🔹 Handle EXCHANGE_STATUS type (navigate to chat)
                        else if (type == "EXCHANGE_STATUS") {
                          final threadId = (dataMap["threadId"] ?? "")
                              .toString();
                          final sellerProfileId =
                              (dataMap["sellerProfileId"] ?? "").toString();

                          if (threadId.isNotEmpty &&
                              sellerProfileId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserChatScreen(
                                  threadId: threadId,
                                  toType: "seller",
                                  toId: sellerProfileId,
                                  title: "Exchange Chat",
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Chat info missing in notification.",
                                ),
                              ),
                            );
                          }
                        }
                        // 🔹 Handle generic chat navigation (if threadId exists)
                        else if (dataMap.containsKey("threadId")) {
                          final threadId = (dataMap["threadId"] ?? "")
                              .toString();
                          final toType = (dataMap["toType"] ?? "seller")
                              .toString();
                          final toId = (dataMap["toId"] ?? "").toString();
                          final title = (n.title ?? "Chat").toString();

                          if (threadId.isNotEmpty && toId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserChatScreen(
                                  threadId: threadId,
                                  toType: toType,
                                  toId: toId,
                                  title: title,
                                ),
                              ),
                            );
                          }
                        }
                         else if (dataMap.containsKey("threadId")) {
                          final threadId = (dataMap["threadId"] ?? "")
                              .toString();
                          final toType = (dataMap["toType"] ?? "seller")
                              .toString();
                          final toId = (dataMap["toId"] ?? "").toString();
                          final title = (n.title ?? "Chat").toString();

                          if (threadId.isNotEmpty && toId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserChatScreen(
                                  threadId: threadId,
                                  toType: toType,
                                  toId: toId,
                                  title: title,
                                ),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final String title;
  final String body;
  final String? image;
  final String? accentColorHex;
  final bool isRead;
  final String? createdAt;
  final VoidCallback onTap;

  const _NotifTile({
    required this.title,
    required this.body,
    required this.onTap,
    required this.isRead,
    this.image,
    this.accentColorHex,
    this.createdAt,
  });

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF2563EB);
    final cleaned = hex.replaceAll("#", "");
    if (cleaned.length == 6) {
      return Color(int.parse("FF$cleaned", radix: 16));
    }
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _parseHex(accentColorHex);
    final absoluteImage = Global.imageUrl + (image ?? "");
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isRead
                ? Colors.black12.withOpacity(0.06)
                : accent.withOpacity(0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52.h,
              width: 52.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                color: accent.withOpacity(0.10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: (absoluteImage.isNotEmpty)
                    ? Image.network(
                        absoluteImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.notifications, color: accent),
                      )
                    : Icon(Icons.notifications, color: accent),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: AppColor.textPrimaryColor,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          height: 8.h,
                          width: 8.w,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.3,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (createdAt != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      _prettyTime(createdAt!),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _prettyTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (_) {
      return "";
    }
  }
}

class _NotifLoading extends StatelessWidget {
  const _NotifLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.only(bottom: 10.h),
        height: 84.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.black12.withOpacity(0.06)),
        ),
      ),
    );
  }
}

class _EmptyNotif extends StatelessWidget {
  const _EmptyNotif();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 56.sp,
              color: Colors.grey[500],
            ),
            SizedBox(height: 10.h),
            Text(
              "No notifications yet",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "When something happens, you'll see it here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
