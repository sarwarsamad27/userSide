// ─── transactionHistory.dart ──────────────────────────────────────────────────
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/walletModel/walletModel.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/viewModel/provider/walletProvider/walletProvider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  void _loadAll() {
    final buyerId = context.read<AuthSession>().userId ?? '';
    if (buyerId.isEmpty) return;
    context.read<WalletProvider>().fetchTransactions(buyerId, type: 'all');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, wallet, _) {
        final buyerId = context.read<AuthSession>().userId ?? '';

        final all = wallet.transactions;
        final credit = all.where((t) => t.isCredit).toList();
        final debit = all.where((t) => !t.isCredit).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: AppColor.appimagecolor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF1A1A2E),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Transaction History',
              style: TextStyle(
                color: const Color(0xFF1A1A2E),
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF1A1A2E),
              unselectedLabelColor: Colors.white,
              indicatorColor: const Color(0xFF1A1A2E),
              indicatorWeight: 2.5,
              labelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
              onTap: (index) {
                final type = ['all', 'credit', 'debit'][index];
                context.read<WalletProvider>().fetchTransactions(
                  buyerId,
                  type: type,
                );
              },
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Credit'),
                Tab(text: 'Debit'),
              ],
            ),
          ),
          body: wallet.txnLoading
              ? Center(child: Utils.loadingLottie(size: 100))
              : Column(
                  children: [
                    // Summary bar
                    _SummaryBar(
                      totalCredit: wallet.totalCredit,
                      totalDebit: wallet.totalDebit,
                    ).animate().fadeIn(duration: 300.ms),

                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _TxnList(transactions: all),
                          _TxnList(transactions: credit),
                          _TxnList(transactions: debit),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final double totalCredit, totalDebit;
  const _SummaryBar({required this.totalCredit, required this.totalDebit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'Total Added',
              amount: totalCredit,
              color: const Color(0xFF00C853),
              icon: Icons.arrow_downward_rounded,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _SummaryCard(
              label: 'Total Spent',
              amount: totalDebit,
              color: const Color(0xFFFF1744),
              icon: Icons.arrow_upward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16.r),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
              ),
              Text(
                'Rs ${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TxnList extends StatelessWidget {
  final List<WalletTransactionModel> transactions;
  const _TxnList({required this.transactions});

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {


final   isJazzcash = transactions.isNotEmpty && transactions.first.method.toLowerCase().contains('jazzcash');
final String logoPath = isJazzcash
    ? 'assets/images/JazzCashLogo.jpg'
    : 'assets/images/easypaisaLogo.jpg';

log('First transaction method: ${transactions.isNotEmpty ? transactions.first.method : 'N/A'}');
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📭', style: TextStyle(fontSize: 48.sp)),
            SizedBox(height: 12.h),
            Text(
              'No transactions yet',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final String methodLower = tx.method.toLowerCase().trim();
  final bool isJazzCash = methodLower == 'send';  // or add more: || methodLower.contains('jazzcash')

  final String logoPath = isJazzCash
      ? 'assets/images/JazzCashLogo.jpg'
      : 'assets/images/easypaisaLogo.jpg';
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child:
              Container(
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
                            color: tx.isCredit
                                ? const Color(0xFF00C853).withOpacity(0.1)
                                : const Color(0xFFFF1744).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Center(
              child: ClipOval(
                child: Image.asset(
                  logoPath,           // ← now correct per transaction
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                tx.subtitle,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _formatDate(tx.createdAt),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${tx.isCredit ? '+' : '-'} Rs ${tx.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: tx.isCredit
                                    ? const Color(0xFF00C853)
                                    : const Color(0xFFFF1744),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: tx.status == 'success'
                                    ? const Color(0xFF00C853).withOpacity(0.1)
                                    : tx.status == 'pending'
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                tx.status == 'success'
                                    ? 'Success'
                                    : tx.status == 'pending'
                                    ? 'Pending'
                                    : 'Failed',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: tx.status == 'success'
                                      ? const Color(0xFF00C853)
                                      : tx.status == 'pending'
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: index * 60))
                  .slideX(begin: 0.05),
        );
      },
    );
  }
}
