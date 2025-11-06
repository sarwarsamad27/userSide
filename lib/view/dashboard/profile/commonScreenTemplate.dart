// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:user_side/widgets/customBgContainer.dart';

// class CommonScreenTemplate extends StatelessWidget {
//   final String title;
//   final Widget body;
//   const CommonScreenTemplate({
//     super.key,
//     required this.title,
//     required this.body,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: CustomBgContainer(
//         child: Padding(padding: EdgeInsets.all(16.w), child: body),
//       ),
//     );
//   }
// }
