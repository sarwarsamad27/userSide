import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/view/dashboard/userChat/emptyState.dart';
import 'package:user_side/view/dashboard/userChat/exchangeRequestCard.dart';
import 'package:user_side/view/dashboard/userChat/messageBubble.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/userChat_provider.dart';

class ChatList extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  
  ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserChatProvider>(
      builder: (_, p, __) {
        if (p.isLoadingHistory) {
          return const Center(child: CircularProgressIndicator());
        }

        if (p.messages.isEmpty) {
          return const EmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          itemCount: p.messages.length,
          itemBuilder: (_, index) {
            final m = p.messages[index];
            if (m.isExchangeRequest == true && m.exchangeData != null) {
              return ExchangeRequestCard(message: m);
            }
            return MessageBubble(message: m);
          },
        );
      },
    );
  }
}
