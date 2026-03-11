import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/walletModel/walletModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/view/dashboard/profile/wallet/addMoney.dart';
import 'package:user_side/view/dashboard/profile/wallet/paymentMethod.dart';
import 'package:user_side/view/dashboard/profile/wallet/sendMoney.dart';
import 'package:user_side/view/dashboard/profile/wallet/transactionHistory.dart';
import 'package:user_side/viewModel/provider/walletProvider/walletProvider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  bool balanceVisible = true;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Fetch balance & recent transactions on load
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final buyerId = context.read<AuthSession>().userId;
    if (buyerId == null) return;
    final provider = context.read<WalletProvider>();
    provider.fetchBalance(buyerId);
    provider.fetchTransactions(buyerId);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return 'Rs ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    }
    return 'Rs ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, wallet, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: CustomScrollView(
            slivers: [
              // ── Gradient AppBar ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: 260.h,
                pinned: true,
                backgroundColor: const Color(0xFF1A1A2E),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.history_rounded,
                      color: Colors.white70,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      _pageRoute(const TransactionHistoryScreen()),
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildWalletCard(wallet),
                ),
                title: Text(
                  'My Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: true,
              ),

              // ── Quick Actions ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
                  child: _buildQuickActions(wallet),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
              ),

              // ── Promo Banner ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: _buildPromoBanner(),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              ),

              // ── Recent Transactions Header ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          _pageRoute(const TransactionHistoryScreen()),
                        ),
                        child: Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms),
              ),

              // ── Transaction List ─────────────────────────────────────
              wallet.txnLoading
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Utils.loadingLottie(size: 100),
                        ),
                      ),
                    )
                  : wallet.transactions.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 30.h),
                          child: Text(
                            'No transactions yet',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tx = wallet.transactions.take(4).toList()[index];
                        return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 5.h,
                              ),
                              child: _TransactionTile(transaction: tx),
                            )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 200 + index * 60),
                            )
                            .slideX(begin: 0.1);
                      }, childCount: wallet.transactions.take(4).length),
                    ),

              SliverToBoxAdapter(child: SizedBox(height: 30.h)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletCard(WalletProvider wallet) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 16.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00E676),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '💳 Wallet',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13.sp,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () => setState(() => balanceVisible = !balanceVisible),
                child: Column(
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    wallet.balanceLoading
                        ? SizedBox(
                            width: 24.r,
                            height: 24.r,
                            child: Utils.loadingLottie(size: 24.r),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                balanceVisible
                                    ? _formatAmount(wallet.balance)
                                    : 'Rs ••••••',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                balanceVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white54,
                                size: 20.r,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(WalletProvider wallet) {
    final buyerId = context.read<AuthSession>().userId ?? '';

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickActionButton(
            icon: Icons.add_rounded,
            label: 'Add Money',
            color: const Color(0xFF00C853),
            onTap: () =>
                Navigator.push(
                  context,
                  _pageRoute(const AddMoneyScreen()),
                ).then((_) {
                  // Refresh balance after returning
                  if (buyerId.isNotEmpty) {
                    context.read<WalletProvider>().fetchBalance(buyerId);
                    context.read<WalletProvider>().fetchTransactions(buyerId);
                  }
                }),
          ),
          _QuickActionButton(
            icon: Icons.send_rounded,
            label: 'Send',
            color: const Color(0xFF2979FF),
            onTap: () =>
                Navigator.push(
                  context,
                  _pageRoute(SendMoneyScreen(balance: wallet.balance)),
                ).then((_) {
                  if (buyerId.isNotEmpty) {
                    context.read<WalletProvider>().fetchBalance(buyerId);
                    context.read<WalletProvider>().fetchTransactions(buyerId);
                  }
                }),
          ),
          _QuickActionButton(
            icon: Icons.credit_card_rounded,
            label: 'Methods',
            color: const Color(0xFFFF6D00),
            onTap: () => Navigator.push(
              context,
              _pageRoute(const PaymentMethodScreen()),
            ),
          ),
          _QuickActionButton(
            icon: Icons.receipt_long_rounded,
            label: 'History',
            color: const Color(0xFF7C4DFF),
            onTap: () => Navigator.push(
              context,
              _pageRoute(const TransactionHistoryScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Text('🎁', style: TextStyle(fontSize: 32.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Top-Up Bonus!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Add Rs 1000+ and get Rs 100 cashback',
                  style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Claim',
              style: TextStyle(
                color: const Color(0xFFFF6B35),
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  PageRouteBuilder _pageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, a, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }
}

// ─── Quick Action Button ──────────────────────────────────────────────────────
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: color, size: 24.r),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final WalletTransactionModel transaction;

  const _TransactionTile({required this.transaction});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: transaction.isCredit
                  ? const Color(0xFF00C853).withOpacity(0.1)
                  : const Color(0xFFFF1744).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                transaction.iconEmoji,
                style: TextStyle(fontSize: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  transaction.subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isCredit ? '+' : '-'} Rs ${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: transaction.isCredit
                      ? const Color(0xFF00C853)
                      : const Color(0xFFFF1744),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                _timeAgo(transaction.createdAt),
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
