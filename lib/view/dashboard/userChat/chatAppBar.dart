import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../resources/appColor.dart';
import '../../../resources/global.dart';
import '../../../viewModel/provider/exchangeProvider/userChat_provider.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? sellerImage;

  const ChatAppBar({
    super.key,
    required this.title,
    this.sellerImage,
  });

  @override
  Widget build(BuildContext context) {
    final isTyping = context.select<UserChatProvider, bool>((p) => p.isTyping);

    return AppBar(
      backgroundColor: AppColor.primaryColor,
      elevation: 1,
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.white,
            backgroundImage: sellerImage != null
                ? NetworkImage(Global.imageUrl + sellerImage!)
                : null,
            child: sellerImage == null
                ? Icon(Icons.store, size: 20.sp, color: AppColor.primaryColor)
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (isTyping)
                  Text(
                    "typing...",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
