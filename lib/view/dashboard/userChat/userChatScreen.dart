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
  // 🔥 Product Context
  final String? productImage;
  final String? productName;
  final String? productPrice;
  final String? productDescription;

  const UserChatScreen({
    super.key,
    required this.threadId,
    required this.toType,
    required this.toId,
    required this.title,
    this.sellerImage,
    this.productImage,
    this.productName,
    this.productPrice,
    this.productDescription,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserChatProvider(
        threadId: threadId,
        toType: toType,
        toId: toId,
        // Pass product context to provider
        initialProductImage: productImage,
        initialProductName: productName,
        initialProductPrice: productPrice,
        initialProductDescription: productDescription,
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
