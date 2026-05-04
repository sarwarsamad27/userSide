import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/userChat_provider.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<UserChatProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Reply preview ──────────────────────────────────────
            if (p.replyTo != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                color: const Color(0xFFF0F0F0),
                child: Row(
                  children: [
                    Container(width: 3, height: 36.h, color: const Color(0xFF128C7E)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.replyTo!.fromType == "buyer" ? "You" : "Seller",
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF128C7E)),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            p.replyTo!.text ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: p.clearReplyTo,
                      child: const Icon(Icons.close, size: 18, color: Colors.black45),
                    ),
                  ],
                ),
              ),

            // ── Input row ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 10.h, bottom: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: TextField(
                        controller: _controller,
                        onChanged: p.onTyping,
                        decoration: InputDecoration(
                          hintText: "Type a message",
                          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.black38),
                          border: InputBorder.none,
                        ),
                        maxLines: 3,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      final text = _controller.text;
                      _controller.clear();
                      p.sendMessage(text);
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: Colors.white, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
