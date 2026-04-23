import 'package:user_side/models/walletModel/walletModel.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class WalletRepository {
  final NetworkApiServices _api = NetworkApiServices();

  // ── Get Wallet Balance ──────────────────────────────────────────────────────
  Future<WalletBalanceModel> getBalance(String buyerId) async {
    try {
      final response = await _api.getApi(
        '${Global.WalletBalance}?buyerId=$buyerId',
      );
      return WalletBalanceModel.fromJson(response);
    } catch (e) {
      return WalletBalanceModel.empty();
    }
  }

  // ── Add Money: Send OTP ─────────────────────────────────────────────────────
  Future<OtpResponseModel> sendAddMoneyOtp({
    required String buyerId,
    required double amount,
    required String method,
    required String phoneNumber,
  }) async {
    try {
      final response = await _api.postApi(Global.AddMoneySendOtp, {
        'buyerId': buyerId,
        'amount': amount,
        'method': method,
        'phoneNumber': phoneNumber,
      });
      return OtpResponseModel.fromJson(response);
    } catch (e) {
      return OtpResponseModel.error(e.toString());
    }
  }

  // ── Add Money: Verify OTP ───────────────────────────────────────────────────
Future<PaymentVerifyModel> verifyAddMoneyOtp({
  required String buyerId,
  required String phoneNumber,
  required String otp,
  String txnRefNo = '',   // ✅
}) async {
  try {
    final response = await _api.postApi(Global.AddMoneyVerifyOtp, {
      'buyerId':   buyerId,
      'phoneNumber': phoneNumber,
      'otp':       otp,
      'txnRefNo':  txnRefNo,   // ✅
    });
    return PaymentVerifyModel.fromJson(response);
  } catch (e) {
    return PaymentVerifyModel.error(e.toString());
  }
}

  // ── Send Money: Send OTP ────────────────────────────────────────────────────
  Future<OtpResponseModel> sendMoneyOtp({
    required String buyerId,
    required double amount,
    required String method,
    required String recipientNumber,
    String note = '',
  }) async {
    try {
      final response = await _api.postApi(Global.SendMoneySendOtp, {
        'buyerId': buyerId,
        'amount': amount,
        'method': method,
        'recipientNumber': recipientNumber,
        'note': note,
      });
      return OtpResponseModel.fromJson(response);
    } catch (e) {
      return OtpResponseModel.error(e.toString());
    }
  }

  // ── Send Money: Verify OTP ──────────────────────────────────────────────────
  Future<PaymentVerifyModel> verifySendMoneyOtp({
    required String buyerId,
    required String otp,
  }) async {
    try {
      final response = await _api.postApi(Global.SendMoneyVerifyOtp, {
        'buyerId': buyerId,
        'otp': otp,
      });
      return PaymentVerifyModel.fromJson(response);
    } catch (e) {
      return PaymentVerifyModel.error(e.toString());
    }
  }
// ── Buyer Withdraw: Send OTP ──────────────────────────────────────────────
Future<OtpResponseModel> sendBuyerWithdrawOtp({
  required String buyerId,
  required double amount,
  required String method,
  required String name,
  required String phone,
}) async {
  try {
    final response = await _api.postApi(Global.BuyerWithdrawSendOtp, {
      'buyerId': buyerId,
      'amount': amount,
      'method': method,
      'name': name,
      'phone': phone,
    });
    return OtpResponseModel.fromJson(response);
  } catch (e) {
    return OtpResponseModel.error(e.toString());
  }
}

// ── Buyer Withdraw: Verify OTP ────────────────────────────────────────────
Future<PaymentVerifyModel> verifyBuyerWithdrawOtp({
  required String buyerId,
  required String otp,
}) async {
  try {
    final response = await _api.postApi(Global.BuyerWithdrawVerifyOtp, {
      'buyerId': buyerId,
      'otp': otp,
    });
    return PaymentVerifyModel.fromJson(response);
  } catch (e) {
    return PaymentVerifyModel.error(e.toString());
  }
}
  // ── Transaction History ─────────────────────────────────────────────────────
  Future<TransactionHistoryModel> getTransactions({
    required String buyerId,
    String type = 'all', // "all" | "credit" | "debit"
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.getApi(
        '${Global.WalletTransactions}?type=$type&page=$page&limit=$limit',
      );
      return TransactionHistoryModel.fromJson(response);
    } catch (e) {
      return TransactionHistoryModel.empty();
    }
  }

  // ── Get Payment Methods ─────────────────────────────────────────────────────
  Future<PaymentMethodsModel> getPaymentMethods(String buyerId) async {
    try {
      final response = await _api.getApi(
        '${Global.PaymentMethods}?buyerId=$buyerId',
      );
      return PaymentMethodsModel.fromJson(response);
    } catch (e) {
      return PaymentMethodsModel.empty();
    }
  }

  // ── Add Payment Method ──────────────────────────────────────────────────────
  Future<bool> addPaymentMethod({
    required String buyerId,
    required String type,
    required String title,
    required String number,
  }) async {
    try {
      await _api.postApi(Global.AddPaymentMethod, {
        'buyerId': buyerId,
        'type': type,
        'title': title,
        'number': number,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Set Default Payment Method ──────────────────────────────────────────────
  Future<bool> setDefaultMethod({
    required String buyerId,
    required String methodId,
  }) async {
    try {
      await _api.putApi(Global.SetDefaultMethod, {
        'buyerId': buyerId,
        'methodId': methodId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Delete Payment Method ───────────────────────────────────────────────────
  Future<bool> deletePaymentMethod({
    required String buyerId,
    required String methodId,
  }) async {
    try {
      await _api.deleteApi(
        '${Global.DeletePaymentMethod}?buyerId=$buyerId&methodId=$methodId',
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  // ── Safepay Checkout ────────────────────────────────────────────────────────
  Future<String?> initSafepayCheckout({
    required String buyerId,
    required double amount,
  }) async {
    try {
      final response = await _api.postApi(Global.SafepayCheckout, {
        'buyerId': buyerId,
        'amount': amount,
      });
      return response['url'] as String?;
    } catch (e) {
      return null;
    }
  }
}
