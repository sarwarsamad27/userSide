import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/chatModel/chatModel.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/userChat_provider.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(ChatMessage)? onReply;

  const MessageBubble({super.key, required this.message, this.onReply});

  void _openImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(child: InteractiveViewer(child: Image.network(url))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.read<UserChatProvider>();
    final isMe = message.fromType == "buyer";
    final isSystem = message.fromType == "system";
    final hasReply = message.replyToId != null;

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

    return _SwipeToReply(
      isMe: isMe,
      onSwipe: onReply != null ? () => onReply!(message) : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            bottom: 8.h,
            left: isMe ? 60.w : 0,
            right: isMe ? 0 : 60.w,
          ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Quoted reply preview ──────────────────────────────
              if (hasReply)
                Container(
                  margin: EdgeInsets.only(bottom: 6.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border(
                      left: BorderSide(
                        color: const Color(0xFF128C7E),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.replyToFromType == "buyer" ? "You" : "Seller",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF128C7E),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      if (message.replyToImageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: Image.network(
                            message.replyToImageUrl!,
                            width: 48.w,
                            height: 48.w,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Text(
                          message.replyToText ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),

              // ── Image ────────────────────────────────────────────
              if (message.imageUrl != null)
                GestureDetector(
                  onTap: () => _openImage(context, message.imageUrl!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      message.imageUrl!,
                      width: 200.w,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : SizedBox(
                              width: 200.w,
                              height: 160.h,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image,
                        size: 40.sp,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                ),

              // ── Message text ──────────────────────────────────────
              if (message.text != null && message.text!.isNotEmpty)
                Text(
                  message.text!,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
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
      ),
    );
  }
}

// ── Swipe-to-reply wrapper ────────────────────────────────────────────────────
class _SwipeToReply extends StatefulWidget {
  final Widget child;
  final bool isMe;
  final VoidCallback? onSwipe;

  const _SwipeToReply({required this.child, required this.isMe, this.onSwipe});

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply> {
  double _offset = 0;
  bool _triggered = false;
  static const double _threshold = 55;

  @override
  Widget build(BuildContext context) {
    if (widget.onSwipe == null) return widget.child;

    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        // Received → swipe right. Sent → swipe left.
        final delta = widget.isMe ? -d.delta.dx : d.delta.dx;
        if (delta > 0) {
          setState(
            () => _offset = (_offset + delta).clamp(0, _threshold * 1.3),
          );
        }
      },
      onHorizontalDragEnd: (_) {
        if (_offset >= _threshold && !_triggered) {
          _triggered = true;
          HapticFeedback.lightImpact();
          widget.onSwipe!();
        }
        setState(() {
          _offset = 0;
          _triggered = false;
        });
      },
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(widget.isMe ? -_offset : _offset, 0),
            child: widget.child,
          ),
          if (_offset > 10)
            Positioned(
              left: widget.isMe ? null : (_offset - 32).clamp(0, 30),
              right: widget.isMe ? (_offset - 32).clamp(0, 30) : null,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: (_offset / _threshold).clamp(0, 1),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F2F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.reply,
                      color: Color(0xFF128C7E),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
