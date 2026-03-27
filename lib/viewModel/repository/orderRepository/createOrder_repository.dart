import 'package:user_side/models/order/createOrder_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';

class CreateOrderRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  // ─────────────────────────────────────────────────────────────────────────
  // Create Order (COD / Wallet / JazzCash)
  // ─────────────────────────────────────────────────────────────────────────
  Future<CreateOrderModel> createOrder({
    required String buyerId,
    required String name,
    required String email,
    required String phone,
    required String address,
    String? additionalNote,
    required List<Map<String, dynamic>> products,
    required int shipmentCharges,
    // ── Payment fields ──────────────────────────────────────────────────────
    String paymentMethod  = 'cod',    // "cod" | "wallet" | "jazzcash"
    String? walletTxnId,              // required for wallet
    String? jazzcashTxnRef,           // required for jazzcash
  }) async {
    final deviceId = await LocalStorage.getOrCreateDeviceId();

    try {
      final Map<String, dynamic> fields = {
        'buyerId': buyerId,
        'buyerDetails': {
          'name':           name,
          'deviceId':       deviceId,
          'email':          email,
          'phone':          phone,
          'address':        address,
          'additionalNote': additionalNote ?? '',
        },
        'products':         products,
        'shipmentCharges':  shipmentCharges,
        // ── Payment ──────────────────────────────────────────────────────
        'paymentMethod':    paymentMethod,
        if (walletTxnId   != null) 'walletTxnId':   walletTxnId,
        if (jazzcashTxnRef != null) 'jazzcashTxnRef': jazzcashTxnRef,
      };

      final response = await apiServices.postApi(Global.CreateOrder, fields);
      return CreateOrderModel.fromJson(response);
    } catch (e) {
      return CreateOrderModel(message: 'Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Wallet OTP — Step 1: Send OTP
  // POST /buyer/wallet/order/send-otp
  // ─────────────────────────────────────────────────────────────────────────
  Future<WalletOtpSendModel> sendWalletOrderOtp({
    required double amount,
    required String phoneNumber,
  }) async {
    try {
      final response = await apiServices.postApi(
        Global.WalletOrderSendOtp,
        {
          'amount':      amount,
          'phoneNumber': phoneNumber,
        },
      );
      return WalletOtpSendModel.fromJson(response);
    } catch (e) {
      return WalletOtpSendModel.error(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Wallet OTP — Step 2: Verify OTP
  // POST /buyer/wallet/order/verify-otp
  // ─────────────────────────────────────────────────────────────────────────
  Future<WalletOtpVerifyModel> verifyWalletOrderOtp({
    required String sessionId,
    required String otp,
  }) async {
    try {
      final response = await apiServices.postApi(
        Global.WalletOrderVerifyOtp,
        {
          'sessionId': sessionId,
          'otp':       otp,
        },
      );
      return WalletOtpVerifyModel.fromJson(response);
    } catch (e) {
      return WalletOtpVerifyModel.error(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JazzCash — Step 1: Initiate payment
  // POST /buyer/jazzcash/pay/initiate
  // ─────────────────────────────────────────────────────────────────────────
  Future<JazzcashInitiateModel> initiateJazzcashPayment({
    required double amount,
    required String mobileNumber,
  }) async {
    try {
      final response = await apiServices.postApi(
        Global.JazzcashPayInitiate,
        {
          'amount':       amount,
          'mobileNumber': mobileNumber,
        },
      );
      return JazzcashInitiateModel.fromJson(response);
    } catch (e) {
      return JazzcashInitiateModel.error(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JazzCash — Step 2: Confirm payment
  // POST /buyer/jazzcash/pay/confirm
  // ─────────────────────────────────────────────────────────────────────────
  Future<JazzcashConfirmModel> confirmJazzcashPayment({
    required String txnRefNo,
  }) async {
    try {
      final response = await apiServices.postApi(
        Global.JazzcashPayConfirm,
        {'txnRefNo': txnRefNo},
      );
      return JazzcashConfirmModel.fromJson(response);
    } catch (e) {
      return JazzcashConfirmModel.error(e.toString());
    }
  }
}