// // ─── paymentMethod.dart ───────────────────────────────────────────────────────
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:user_side/models/walletModel/walletModel.dart';
// import 'package:user_side/resources/authSession.dart';
// import 'package:user_side/resources/utiles.dart';
// import 'package:user_side/viewModel/provider/walletProvider/walletProvider.dart';

// class PaymentMethodScreen extends StatefulWidget {
//   const PaymentMethodScreen({super.key});

//   @override
//   State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
// }

// class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final buyerId = context.read<AuthSession>().userId ?? '';
//       if (buyerId.isNotEmpty) {
//         context.read<WalletProvider>().fetchPaymentMethods(buyerId);
//       }
//     });
//   }

//   String get _buyerId => context.read<AuthSession>().userId ?? '';

//   void _setDefault(String methodId) async {
//     await context.read<WalletProvider>().setDefaultMethod(
//       buyerId: _buyerId,
//       methodId: methodId,
//     );
//   }

//   void _delete(String methodId) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         title: Text(
//           'Remove Method?',
//           style: TextStyle(
//             fontSize: 17.sp,
//             fontWeight: FontWeight.w700,
//             color: const Color(0xFF1A1A2E),
//           ),
//         ),
//         content: Text(
//           'This payment method will be removed.',
//           style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await context.read<WalletProvider>().deleteMethod(
//                 buyerId: _buyerId,
//                 methodId: methodId,
//               );
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: const Text('Payment method removed'),
//                     backgroundColor: Colors.red.shade600,
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                   ),
//                 );
//               }
//             },
//             child: Text(
//               'Remove',
//               style: TextStyle(
//                 color: Colors.red.shade600,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<WalletProvider>(
//       builder: (context, wallet, _) {
//         return Scaffold(
//           backgroundColor: const Color(0xFFF5F6FA),
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Color(0xFF1A1A2E),
//                 size: 20,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: Text(
//               'Payment Methods',
//               style: TextStyle(
//                 color: const Color(0xFF1A1A2E),
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             centerTitle: true,
//           ),
//           body: wallet.methodsLoading
//               ?  Center(child: Utils.loadingLottie(size: 100))
//               : SingleChildScrollView(
//                   padding: EdgeInsets.all(16.r),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 8.h),

//                       // Info card
//                       Container(
//                         padding: EdgeInsets.all(14.r),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF1A1A2E).withOpacity(0.05),
//                           borderRadius: BorderRadius.circular(14.r),
//                         ),
//                         child: Row(
//                           children: [
//                             Text('💡', style: TextStyle(fontSize: 20.sp)),
//                             SizedBox(width: 10.w),
//                             Expanded(
//                               child: Text(
//                                 'Your payment methods are saved securely.',
//                                 style: TextStyle(
//                                   fontSize: 12.sp,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ).animate().fadeIn(duration: 300.ms),

//                       SizedBox(height: 20.h),

//                       Text(
//                         'Saved Methods',
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.w700,
//                           color: const Color(0xFF1A1A2E),
//                         ),
//                       ),
//                       SizedBox(height: 12.h),

//                       if (wallet.paymentMethods.isEmpty)
//                         Center(
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(vertical: 40.h),
//                             child: Column(
//                               children: [
//                                 Text('💳', style: TextStyle(fontSize: 48.sp)),
//                                 SizedBox(height: 12.h),
//                                 Text(
//                                   'No saved methods',
//                                   style: TextStyle(
//                                     fontSize: 15.sp,
//                                     color: Colors.grey.shade400,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                       else
//                         ...List.generate(wallet.paymentMethods.length, (i) {
//                           final method = wallet.paymentMethods[i];
//                           return Padding(
//                                 padding: EdgeInsets.only(bottom: 10.h),
//                                 child: _MethodCard(
//                                   method: method,
//                                   onSetDefault: () => _setDefault(method.id),
//                                   onDelete: () => _delete(method.id),
//                                 ),
//                               )
//                               .animate()
//                               .fadeIn(delay: Duration(milliseconds: i * 80))
//                               .slideX(begin: 0.1);
//                         }),

//                       SizedBox(height: 20.h),

//                       Text(
//                         'Add New Method',
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.w700,
//                           color: const Color(0xFF1A1A2E),
//                         ),
//                       ),
//                       SizedBox(height: 12.h),

//                       _AddMethodCard(
//                         type: 'easypaisa',
//                         name: 'EasyPaisa',

//                         color: const Color(0xFF00A650),
//                         bgColor: const Color(0xFFE8F5E9),
//                         onAdd: (number, title) async {
//                           await context.read<WalletProvider>().addPaymentMethod(
//                             buyerId: _buyerId,
//                             type: 'easypaisa',
//                             title: title,
//                             number: number,
//                           );
//                         },
//                       ).animate().fadeIn(delay: 200.ms),

//                       SizedBox(height: 10.h),

//                       _AddMethodCard(
//                         type: 'jazzcash',
//                         name: 'JazzCash',
//                         isJazzcash: true,
//                         color: const Color(0xFFCC0000),
//                         bgColor: const Color(0xFFFFF0F0),
//                         onAdd: (number, title) async {
//                           await context.read<WalletProvider>().addPaymentMethod(
//                             buyerId: _buyerId,
//                             type: 'jazzcash',
//                             title: title,
//                             number: number,
//                           );
//                         },
//                       ).animate().fadeIn(delay: 250.ms),

//                       SizedBox(height: 30.h),
//                     ],
//                   ),
//                 ),
//         );
//       },
//     );
//   }
// }

// class _MethodCard extends StatelessWidget {
//   final SavedPaymentMethodModel method;
//   final VoidCallback onSetDefault, onDelete;

//   const _MethodCard({
//     required this.method,
//     required this.onSetDefault,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isJazzcash = method.type == 'jazzcash';
//      final String logoPath = isJazzcash
//         ? 'assets/images/JazzCashLogo.jpg'
//         : 'assets/images/easypaisaLogo.jpg';
//     final isEasypaisa = method.type == 'easypaisa';
//     final color = isEasypaisa
//         ? const Color(0xFF00A650)
//         : const Color(0xFFCC0000);
//     final bgColor = isEasypaisa
//         ? const Color(0xFFE8F5E9)
//         : const Color(0xFFFFF0F0);

//     return Container(
//       padding: EdgeInsets.all(16.r),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: method.isDefault
//             ? Border.all(color: color.withOpacity(0.4), width: 1.5)
//             : null,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 46.r,
//             height: 46.r,
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius: BorderRadius.circular(14.r),
//             ),
//             child: Center(
//   child: Image.asset(
//     logoPath,
//     width: 26.r,
//     height: 26.r,
//     fit: BoxFit.contain,
//   ),
// ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       method.title,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w700,
//                         color: const Color(0xFF1A1A2E),
//                       ),
//                     ),
//                     if (method.isDefault) ...[
//                       SizedBox(width: 8.w),
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 8.w,
//                           vertical: 2.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: color.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(10.r),
//                         ),
//                         child: Text(
//                           'Default',
//                           style: TextStyle(
//                             fontSize: 10.sp,
//                             fontWeight: FontWeight.w600,
//                             color: color,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//                 SizedBox(height: 3.h),
//                 Text(
//                   method.number,
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     color: Colors.grey.shade500,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuButton<String>(
//             onSelected: (val) {
//               if (val == 'default') onSetDefault();
//               if (val == 'delete') onDelete();
//             },
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             itemBuilder: (_) => const [
//               PopupMenuItem(
//                 value: 'default',
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.star_outline_rounded,
//                       size: 18,
//                       color: Color(0xFF1A1A2E),
//                     ),
//                     SizedBox(width: 10),
//                     Text('Set as Default'),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: 'delete',
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.delete_outline_rounded,
//                       size: 18,
//                       color: Colors.red,
//                     ),
//                     SizedBox(width: 10),
//                     Text('Remove', style: TextStyle(color: Colors.red)),
//                   ],
//                 ),
//               ),
//             ],
//             icon: Icon(
//               Icons.more_vert_rounded,
//               color: Colors.grey.shade400,
//               size: 20.r,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AddMethodCard extends StatelessWidget {
//   final String type, name;
//   final bool isJazzcash; // ✅ false = easypaisa (default), true = jazzcash
//   final Color color, bgColor;
//   final Function(String number, String title) onAdd;

//   const _AddMethodCard({
//     required this.type,
//     required this.name,
//     this.isJazzcash = false, // ✅ default: easypaisa
//     required this.color,
//     required this.bgColor,
//     required this.onAdd,
//   });

//   @override
//   Widget build(BuildContext context) {
//   final String logoPath = isJazzcash
//     ? 'assets/images/JazzCashLogo.jpg'
//     : 'assets/images/easypaisaLogo.jpg';

//     return GestureDetector(
//       onTap: () => _showAddSheet(context),
//       child: Container(
//         padding: EdgeInsets.all(16.r),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 46.r,
//               height: 46.r,
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(14.r),
//               ),
//               child: Center(
//   child: Image.asset(
//     logoPath,
//     width: 26.r,
//     height: 26.r,
//     fit: BoxFit.contain,
//   ),
// ),
//             ),
//             SizedBox(width: 14.w),
//             Expanded(
//               child: Text(
//                 'Add $name Account',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF1A1A2E),
//                 ),
//               ),
//             ),
//             Container(
//               width: 32.r,
//               height: 32.r,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10.r),
//               ),
//               child: Icon(Icons.add_rounded, color: color, size: 20.r),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAddSheet(BuildContext context) {
//     final numberCtrl = TextEditingController();
//     final titleCtrl = TextEditingController(text: 'My $name');
//     final formKey = GlobalKey<FormState>();
// final String logoPath = isJazzcash
//     ? 'assets/images/JazzCashLogo.jpg'
//     : 'assets/images/easypaisaLogo.jpg';
   

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Container(
//           padding: EdgeInsets.all(24.r),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24.r),
//               topRight: Radius.circular(24.r),
//             ),
//           ),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40.w,
//                     height: 4.h,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(2.r),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 Row(
//                   children: [
//                     // ✅ Sheet header mein bhi logo
//                     Container(
//                       width: 28.r,
//                       height: 28.r,
//                       decoration: BoxDecoration(
//                         color: bgColor,
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       child: CircleAvatar(
//                         child: Image.asset(
//                           logoPath,
//                           width: 20.r,
//                           height: 20.r,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10.w),
//                     Text(
//                       'Add $name Account',
//                       style: TextStyle(
//                         fontSize: 17.sp,
//                         fontWeight: FontWeight.w700,
//                         color: const Color(0xFF1A1A2E),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20.h),
//                 Text(
//                   'Account Title',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 TextFormField(
//                   controller: titleCtrl,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: const Color(0xFFF5F6FA),
//                     hintText: 'e.g. My $name',
//                     hintStyle: TextStyle(color: Colors.grey.shade300),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 14.w,
//                       vertical: 14.h,
//                     ),
//                   ),
//                   validator: (v) =>
//                       v == null || v.isEmpty ? 'Enter title' : null,
//                 ),
//                 SizedBox(height: 14.h),
//                 Text(
//                   'Mobile Number',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 TextFormField(
//                   controller: numberCtrl,
//                   keyboardType: TextInputType.phone,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(11),
//                   ],
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: const Color(0xFFF5F6FA),
//                     hintText: '03XXXXXXXXX',
//                     hintStyle: TextStyle(color: Colors.grey.shade300),
//                     prefixText: '+92  ',
//                     prefixStyle: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 14.w,
//                       vertical: 14.h,
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.isEmpty) return 'Enter number';
//                     if (v.length < 10) return 'Enter valid number';
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 24.h),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50.h,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (formKey.currentState!.validate()) {
//                         onAdd(numberCtrl.text, titleCtrl.text);
//                         Navigator.pop(context);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('$name account added! ✅'),
//                             backgroundColor: color,
//                             behavior: SnackBarBehavior.floating,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: color,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14.r),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: Text(
//                       'Add Account',
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
