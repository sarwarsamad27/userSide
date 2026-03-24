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

  // ── Payment Methods ───────────────────────────────────────────────────────
  List<SavedPaymentMethodModel> paymentMethods = [];
  bool methodsLoading = false;

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

  // ── Fetch Payment Methods ──────────────────────────────────────────────────
  Future<void> fetchPaymentMethods(String buyerId) async {
    methodsLoading = true;
    notifyListeners();

    final result = await _repo.getPaymentMethods(buyerId);
    if (result.success) {
      paymentMethods = result.methods;
    }

    methodsLoading = false;
    notifyListeners();
  }

  // ── Add Money: Send OTP ────────────────────────────────────────────────────
  // Returns true if OTP sent successfully
  Future<bool> sendAddMoneyOtp({
    required String buyerId,
    required double amount,
    required String method,
    required String phoneNumber,
  }) async {
    otpLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _repo.sendAddMoneyOtp(
      buyerId: buyerId,
      amount: amount,
      method: method,
      phoneNumber: phoneNumber,
    );

    otpLoading = false;
    if (!result.success) {
      errorMessage = result.message;
    }
    notifyListeners();
    return result.success;
  }

  // ── Add Money: Verify OTP → credit balance ─────────────────────────────────
  // Returns PaymentVerifyModel (has txnId, amount etc. for PaymentSuccessScreen)
  Future<PaymentVerifyModel?> verifyAddMoneyOtp({
    required String buyerId,
    required String phoneNumber,
    required String otp,
  }) async {
    verifyLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _repo.verifyAddMoneyOtp(
      buyerId: buyerId,
      phoneNumber: phoneNumber,
      otp: otp,
    );

    if (result.success) {
      balance = result.newBalance; // update balance instantly
    } else {
      errorMessage = result.message;
    }

    verifyLoading = false;
    notifyListeners();
    return result.success ? result : null;
  }

  // ── Send Money: Send OTP ───────────────────────────────────────────────────
  Future<bool> sendMoneyOtp({
    required String buyerId,
    required double amount,
    required String method,
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

  // ── Send Money: Verify OTP → debit balance ─────────────────────────────────
  Future<PaymentVerifyModel?> verifySendMoneyOtp({
    required String buyerId,
    required String otp,
  }) async {
    verifyLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _repo.verifySendMoneyOtp(
      buyerId: buyerId,
      otp: otp,
    );

    if (result.success) {
      balance = result.newBalance;
    } else {
      errorMessage = result.message;
    }

    verifyLoading = false;
    notifyListeners();
    return result.success ? result : null;
  }

  // ── Add Payment Method ─────────────────────────────────────────────────────
  Future<bool> addPaymentMethod({
    required String buyerId,
    required String type,
    required String title,
    required String number,
  }) async {
    final success = await _repo.addPaymentMethod(
      buyerId: buyerId,
      type: type,
      title: title,
      number: number,
    );
    if (success) await fetchPaymentMethods(buyerId);
    return success;
  }

  // ── Set Default Payment Method ─────────────────────────────────────────────
  Future<void> setDefaultMethod({
    required String buyerId,
    required String methodId,
  }) async {
    await _repo.setDefaultMethod(buyerId: buyerId, methodId: methodId);
    await fetchPaymentMethods(buyerId);
  }

  // ── Delete Payment Method ──────────────────────────────────────────────────
  Future<void> deleteMethod({
    required String buyerId,
    required String methodId,
  }) async {
    await _repo.deletePaymentMethod(buyerId: buyerId, methodId: methodId);
    await fetchPaymentMethods(buyerId);
  }

  // ── Safepay Checkout: Initiate payment session ──────────────────────────────
  Future<String?> initSafepayCheckout({
    required String buyerId,
    required double amount,
  }) async {
    otpLoading = true;
    errorMessage = '';
    notifyListeners();

    final url = await _repo.initSafepayCheckout(
      buyerId: buyerId,
      amount: amount,
    );

    otpLoading = false;
    if (url == null) {
      errorMessage = "Could not initialize Safepay. Try again.";
    }
    notifyListeners();
    return url;
  }

  // ── Clear error ────────────────────────────────────────────────────────────
  void clearError() {
    errorMessage = '';
    notifyListeners();
  }
}