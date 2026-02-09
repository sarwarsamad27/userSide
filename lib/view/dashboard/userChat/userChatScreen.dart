import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_side/view/dashboard/userChat/chatAppBar.dart';
import 'package:user_side/view/dashboard/userChat/chatList.dart';
import 'package:user_side/view/dashboard/userChat/messageInput.dart';
import 'package:user_side/view/dashboard/userChat/typingIndicator.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/userChat_provider.dart';

class UserChatScreen extends StatelessWidget {
  final String threadId;
  final String toType;
  final String toId;
  final String title;
  final String? sellerImage;
  
  // ✅ CHANGED: Use Map instead of String
  final Map<String, dynamic>? initialProductData;
  final String? initialMessage;

  const UserChatScreen({
    super.key,
    required this.threadId,
    required this.toType,
    required this.toId,
    required this.title,
    this.sellerImage,
    this.initialProductData, // ✅ Changed type
    this.initialMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserChatProvider(
        threadId: threadId,
        toType: toType,
        toId: toId,
        initialProductData: initialProductData, // ✅ Pass Map
        initialMessage: initialMessage,
      )..init(),
      child: Scaffold(
        backgroundColor: const Color(0xFFECE5DD),
        appBar: ChatAppBar(title: title, sellerImage: sellerImage),
        body: Column(
          children: [
            Expanded(child: ChatList()),
            Consumer<UserChatProvider>(
              builder: (_, p, __) => p.isTyping
                  ? const TypingIndicator()
                  : const SizedBox.shrink(),
            ),
            const MessageInput(),
          ],
        ),
      ),
    );
  }
}