import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqs = [
    (
      q: 'How can I track my order?',
      a: 'Go to "My Orders" in your profile and tap on the order to view its current status and tracking details.',
    ),
    (
      q: 'Can I cancel my order?',
      a: 'Orders can be canceled before they are dispatched. Go to your order details and tap "Cancel Order".',
    ),
    (
      q: 'What payment methods are accepted?',
      a: 'We accept Cash on Delivery and Wallet payments. More methods coming soon.',
    ),
    (
      q: 'How do I return or exchange a product?',
      a: 'Visit your order details, select the delivered item, and tap "Exchange" or "Refund". Available within 10 days of delivery.',
    ),
    (
      q: 'How long does delivery take?',
      a: 'Standard delivery takes 3–7 business days depending on your location.',
    ),
    (
      q: 'How Can I give review?',
      a: 'Go to "Order History" in your profile, select the delivered order, and tap "Add Review" to share your feedback. And you are able to give only one review for each order. If you want to update your review, please contact our support team through the "Contact Us" section in the Help Center.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help Center',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Banner ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 28.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How can we\nhelp you?',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E1E2D),
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Browse FAQs or reach our\nsupport team anytime.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: AppColor.primaryColor,
                      size: 36.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ── Contact Options ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E2D),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _ContactCard(
                    icon: Icons.phone_rounded,
                    label: 'Call Support',
                    value: '+92 300 0000000',
                    color: const Color(0xFF10B981),
                    onTap: () {},
                  ),
                  SizedBox(height: 10.h),
                  _ContactCard(
                    icon: Icons.email_rounded,
                    label: 'Email Us',
                    value: 'support@shookoo.com',
                    color: const Color(0xFF3B82F6),
                    onTap: () {},
                  ),
                  SizedBox(height: 10.h),
                  _ContactCard(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Live Chat',
                    value: 'Available 9 AM – 9 PM',
                    color: AppColor.primaryColor,
                    onTap: () {},
                  ),

                  SizedBox(height: 28.h),

                  // ── FAQ Section ────────────────────────────────────────
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E2D),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  ...List.generate(_faqs.length, (i) {
                    final faq = _faqs[i];
                    return _FaqTile(question: faq.q, answer: faq.a);
                  }),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E2D),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.question,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E1E2D),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      RotationTransition(
                        turns: _rotate,
                        child: Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColor.primaryColor,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_expanded) ...[
                    SizedBox(height: 10.h),
                    Container(height: 1, color: Colors.grey.shade100),
                    SizedBox(height: 10.h),
                    Text(
                      widget.answer,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        height: 1.55,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
