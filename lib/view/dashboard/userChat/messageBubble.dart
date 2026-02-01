import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/chatModel/chatModel.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/userChat_provider.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final p = context.read<UserChatProvider>();

    final isMe = message.fromType == "buyer";
    final isSystem = message.fromType == "system";
    if (isSystem) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            message.text ?? "",
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h, left: isMe ? 60.w : 0, right: isMe ? 0 : 60.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 12.r : 0),
            topRight: Radius.circular(isMe ? 0 : 12.r),
            bottomLeft: Radius.circular(12.r),
            bottomRight: Radius.circular(12.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.text ?? "", style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.formatTime(message.timestamp),
                  style: TextStyle(fontSize: 11.sp, color: Colors.black45),
                ),
                if (isMe) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message.readAt != null
                        ? Icons.done_all
                        : message.deliveredAt != null
                            ? Icons.done_all
                            : Icons.done,
                    size: 14.sp,
                    color: message.readAt != null
                        ? Colors.blue
                        : message.deliveredAt != null
                            ? Colors.black45
                            : Colors.black26,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
