// ─── walletProvider.dart ──────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:user_side/models/walletModel/walletModel.dart';
import 'package:user_side/viewModel/repository/walletRepository/wallet_repository.dart';

class WalletProvider with ChangeNotifier {
  final WalletRepository _repo = WalletRepository();

  // ── Balance ───────────────────────────────────────────────────────────────
  double balance = 0.0;
  bool balanceLoading = false;

  // ── Transactions ──────────────────────────────────────────────────────────
  List<WalletTransactionModel> transactions = [];
  double totalCredit = 0.0;
  double totalDebit = 0.0;
  bool txnLoading = false;

  // ── OTP / Payment flow ────────────────────────────────────────────────────
  bool otpLoading = false;
  bool verifyLoading = false;
  String errorMessage = '';

  // ── Fetch Balance ─────────────────────────────────────────────────────────
  Future<void> fetchBalance(String buyerId) async {
    balanceLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _repo.getBalance(buyerId);
    if (result.success) {
      balance = result.balance;
    }

    balanceLoading = false;
    notifyListeners();
  }

  // ── Fetch Transactions ─────────────────────────────────────────────────────
  Future<void> fetchTransactions(
    String buyerId, {
    String type = 'all',
    int page = 1,
  }) async {
    txnLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _repo.getTransactions(
      buyerId: buyerId,
      type: type,
      page: page,
    );

    if (result.success) {
      transactions = result.transactions;
      totalCredit = result.totalCredit;
      totalDebit = result.totalDebit;
      balance = result.balance;
    }

    txnLoading = false;
    notifyListeners();
  }

  // ── Add Money: Safepay Checkout ─────────────────────────────────────────────
  String? lastTrackId;

  // trackIds whose checkout screen was closed before the poll resolved —
  // without this, the loop below keeps hitting the backend every few
  // seconds for up to ~2 minutes after the user has already left the screen.
  final Set<String> _cancelledTrackIds = {};

  void cancelPolling(String trackId) => _cancelledTrackIds.add(trackId);

  Future<SafepayCheckoutModel> initSafepayCheckout({
    required double amount,
  }) async {
    otpLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _repo.initSafepayCheckout(amount: amount);

    otpLoading = false;
    if (!result.success) {
      errorMessage = result.message.isNotEmpty
          ? result.message
          : 'Failed to start payment. Try again.';
    } else {
      lastTrackId = result.trackId;
    }
    notifyListeners();
    return result;
  }

  /// Polls the backend for the webhook-driven completion of a Safepay
  /// checkout. Returns the terminal status once it's no longer "pending",
  /// or a "pending" result if [maxAttempts] is reached first.
  Future<SafepayStatusModel> pollSafepayStatus(
    String trackId, {
    Duration interval = const Duration(seconds: 3),
    int maxAttempts = 40, // ~2 minutes
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      if (_cancelledTrackIds.remove(trackId)) {
        return SafepayStatusModel.error('cancelled');
      }
      final result = await _repo.getSafepayStatus(trackId);
      if (!result.isPending) {
        if (result.isSuccess && result.newBalance != null) {
          balance = result.newBalance!;
          notifyListeners();
        }
        return result;
      }
      await Future.delayed(interval);
    }
    _cancelledTrackIds.remove(trackId);
    return SafepayStatusModel.pending('Payment confirmation timed out');
  }

  // ── Send Money: Send OTP ───────────────────────────────────────────────────
  Future<bool> sendMoneyOtp({
    required String buyerId,
    required double amount,
    required String method, // always 'jazzcash'
    required String recipientNumber,
    String note = '',
  }) async {
    otpLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _repo.sendMoneyOtp(
      buyerId: buyerId,
      amount: amount,
      method: method,
      recipientNumber: recipientNumber,
      note: note,
    );

    otpLoading = false;
    if (!result.success) {
      errorMessage = result.message;
    }
    notifyListeners();
    return result.success;
  }

  // ── Buyer Withdraw: Send OTP ──────────────────────────────────────────────
  Future<bool> sendBuyerWithdrawOtp({
    required String buyerId,
    required double amount,
    required String method,
    required String name,
    required String phone,
    String? bankName,
    String? accountNumber,
    String? iban,
  }) async {
    otpLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _repo.sendBuyerWithdrawOtp(
      buyerId: buyerId,
      amount: amount,
      method: method,
      name: name,
      phone: phone,
      bankName: bankName,
      accountNumber: accountNumber,
      iban: iban,
    );

    otpLoading = false;
    if (!result.success) errorMessage = result.message;
    notifyListeners();
    return result.success;
  }

  // ── Buyer Withdraw: Verify OTP ────────────────────────────────────────────
  Future<PaymentVerifyModel?> verifyBuyerWithdrawOtp({
    required String buyerId,
    required String otp,
  }) async {
    verifyLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _repo.verifyBuyerWithdrawOtp(
      buyerId: buyerId,
      otp: otp,
    );

    verifyLoading = false;

    if (result.success) {
      // ✅ Balance update karo — backend se naya balance aaya
      if (result.newBalance > 0 || result.newBalance == 0) {
        balance = result.newBalance;
      }
    } else {
      errorMessage = result.message;
    }

    notifyListeners();
    return result.success ? result : null;
  }

  // ── Send Money: Verify OTP → debit balance ─────────────────────────────────
  Future<PaymentVerifyModel?> verifySendMoneyOtp({
    required String buyerId,
    required String otp,
  }) async {
    verifyLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _repo.verifySendMoneyOtp(buyerId: buyerId, otp: otp);

    if (result.success) {
      balance = result.newBalance;
    } else {
      errorMessage = result.message;
    }

    verifyLoading = false;
    notifyListeners();
    return result.success ? result : null;
  }

  // ── Clear error ────────────────────────────────────────────────────────────
  void clearError() {
    errorMessage = '';
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  REMOVED:
  //  - fetchPaymentMethods()   → Payment Methods screen removed
  //  - addPaymentMethod()      → Payment Methods screen removed
  //  - setDefaultMethod()      → Payment Methods screen removed
  //  - deleteMethod()          → Payment Methods screen removed
  // ═══════════════════════════════════════════════════════════════════════════
}
