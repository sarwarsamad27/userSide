import 'package:flutter/material.dart';
import 'package:user_side/models/order/createOrder_model.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/repository/orderRepository/createOrder_repository.dart';

/// ══════════════════════════════════════════════════════════
///  CreateOrderProvider — Full Payment Flow
///
///  Supported paymentMethod values:
///   'cod'      → placeOrder(paymentMethod: 'cod')
///   'wallet'   → sendWalletOtp() → verifyWalletOtp() → placeOrder()
///   'jazzcash' → initiateJazzcash() → (user confirms in JC app)
///                → confirmJazzcash() → placeOrder()
/// ══════════════════════════════════════════════════════════

class CreateOrderProvider with ChangeNotifier {
  final CreateOrderRepository repository = CreateOrderRepository();

  // ── Order state ────────────────────────────────────────────────────────────
  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CreateOrderModel? _orderData;
  CreateOrderModel? get orderData => _orderData;

  // ── Wallet OTP state ───────────────────────────────────────────────────────
  bool _walletOtpLoading = false;
  bool get walletOtpLoading => _walletOtpLoading;

  bool _walletVerifyLoading = false;
  bool get walletVerifyLoading => _walletVerifyLoading;

  String? _walletSessionId;          // from send-otp, used in verify-otp
  String? _walletTxnId;              // from verify-otp, passed to createOrder
  double? _walletNewBalance;         // updated balance after debit
  double? get walletNewBalance => _walletNewBalance;

  // ── JazzCash state ─────────────────────────────────────────────────────────
  bool _jazzcashLoading = false;
  bool get jazzcashLoading => _jazzcashLoading;

  String? _jazzcashTxnRef;           // from initiate, used in confirm + createOrder
  bool _jazzcashConfirmed = false;
  bool get jazzcashConfirmed => _jazzcashConfirmed;

  // ──────────────────────────────────────────────────────────────────────────
  // STEP: Place Order (COD / after wallet OTP / after jazzcash confirm)
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> placeOrder({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? additionalNote,
    required List<Map<String, dynamic>> products,
    required int shipmentCharges,
    String paymentMethod = 'cod',
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? buyerId = await LocalStorage.getUserId();
      if (buyerId == null) {
        _errorMessage = 'User not logged in';
        _loading = false;
        notifyListeners();
        return;
      }

      _orderData = await repository.createOrder(
        buyerId:         buyerId,
        name:            name,
        email:           email,
        phone:           phone,
        address:         address,
        additionalNote:  additionalNote,
        products:        products,
        shipmentCharges: shipmentCharges,
        paymentMethod:   paymentMethod,
        // Attach pre-verified payment refs
        walletTxnId:     paymentMethod == 'wallet'   ? _walletTxnId   : null,
        jazzcashTxnRef:  paymentMethod == 'jazzcash' ? _jazzcashTxnRef : null,
      );

      // Clear payment refs after successful order
      if (_orderData?.order != null) {
        _walletTxnId    = null;
        _jazzcashTxnRef = null;
        _jazzcashConfirmed = false;
      } else {
        _errorMessage = _orderData?.message ?? 'Failed to place order';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _loading = false;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // WALLET FLOW — Step 1: Send OTP
  // Call this when user taps "Confirm" on wallet payment selection
  // Returns true if OTP sent successfully
  // ──────────────────────────────────────────────────────────────────────────
  Future<bool> sendWalletOtp({
    required double amount,
    required String phoneNumber,
  }) async {
    _walletOtpLoading = true;
    _errorMessage = null;
    _walletSessionId = null;
    notifyListeners();

    final result = await repository.sendWalletOrderOtp(
      amount:      amount,
      phoneNumber: phoneNumber,
    );

    _walletOtpLoading = false;

    if (result.success) {
      _walletSessionId = result.sessionId;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // WALLET FLOW — Step 2: Verify OTP
  // Returns true if OTP correct and wallet debited
  // After this, call placeOrder(paymentMethod: 'wallet')
  // ──────────────────────────────────────────────────────────────────────────
  Future<bool> verifyWalletOtp({required String otp}) async {
    if (_walletSessionId == null) {
      _errorMessage = 'Session expired. Please request a new OTP.';
      notifyListeners();
      return false;
    }

    _walletVerifyLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.verifyWalletOrderOtp(
      sessionId: _walletSessionId!,
      otp:       otp,
    );

    _walletVerifyLoading = false;

    if (result.success) {
      _walletTxnId      = result.txnId;
      _walletNewBalance = result.newBalance;
      _walletSessionId  = null;   // clear session
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // JAZZCASH FLOW — Step 1: Initiate
  // Returns (success: bool, message: String)
  // On success → user goes to JazzCash app to approve
  // ──────────────────────────────────────────────────────────────────────────
  Future<({bool success, String message, bool autoApproved})> initiateJazzcash({
    required double amount,
    required String mobileNumber,
  }) async {
    _jazzcashLoading = true;
    _errorMessage = null;
    _jazzcashTxnRef = null;
    _jazzcashConfirmed = false;
    notifyListeners();

    final result = await repository.initiateJazzcashPayment(
      amount:       amount,
      mobileNumber: mobileNumber,
    );

    _jazzcashLoading = false;

    if (result.success) {
      _jazzcashTxnRef = result.txnRefNo;
      notifyListeners();
      return (success: true, message: result.message, autoApproved: result.autoApproved);
    } else {
      _errorMessage = result.message;
      notifyListeners();
      return (success: false, message: result.message, autoApproved: false);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // JAZZCASH FLOW — Step 2: Confirm (after user approves in JazzCash app)
  // Returns true if payment confirmed
  // After this, call placeOrder(paymentMethod: 'jazzcash')
  // ──────────────────────────────────────────────────────────────────────────
  Future<bool> confirmJazzcash() async {
    if (_jazzcashTxnRef == null) {
      _errorMessage = 'No pending JazzCash transaction. Please initiate again.';
      notifyListeners();
      return false;
    }

    _jazzcashLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.confirmJazzcashPayment(
      txnRefNo: _jazzcashTxnRef!,
    );

    _jazzcashLoading = false;

    if (result.success && result.confirmed) {
      _jazzcashConfirmed = true;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  bool get walletPaymentReady   => _walletTxnId != null;
  bool get jazzcashPaymentReady => _jazzcashTxnRef != null && _jazzcashConfirmed;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetPayment() {
    _walletTxnId       = null;
    _walletSessionId   = null;
    _walletNewBalance  = null;
    _jazzcashTxnRef    = null;
    _jazzcashConfirmed = false;
    _errorMessage      = null;
    notifyListeners();
  }
}