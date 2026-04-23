// ─── Wallet Balance Model ──────────────────────────────────────────────────────
class WalletBalanceModel {
  final bool success;
  final String walletId;
  final double balance;

  WalletBalanceModel({
    required this.success,
    required this.walletId,
    required this.balance,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      success: true,
      walletId: json['walletId'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory WalletBalanceModel.empty() =>
      WalletBalanceModel(success: false, walletId: '', balance: 0.0);
}

// ─── Transaction Model ────────────────────────────────────────────────────────
class WalletTransactionModel {
  final String txnId;
  final String title;
  final String subtitle;
  final String iconEmoji;
  final double amount;
  final String type; // "credit" | "debit"
  final String status; // "success" | "pending" | "failed"
  final String method;
  final String? phoneNumber;
  final String? note;
  final DateTime createdAt;
  

  bool get isCredit => type == 'credit';

  WalletTransactionModel({
    required this.txnId,
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.amount,
    required this.type,
    required this.status,
    required this.method,
    this.phoneNumber,
    this.note,
    required this.createdAt,
   
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      txnId: json['txnId'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      iconEmoji: json['iconEmoji'] ?? '💳',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? 'debit',
      status: json['status'] ?? 'success',
      method: json['method'] ?? '',
      phoneNumber: json['phoneNumber'],
      note: json['note'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ─── Transaction History Response ─────────────────────────────────────────────
class TransactionHistoryModel {
  final bool success;
  final double balance;
  final double totalCredit;
  final double totalDebit;
  final int total;
  final int page;
  final int pages;
  final List<WalletTransactionModel> transactions;

  TransactionHistoryModel({
    required this.success,
    required this.balance,
    required this.totalCredit,
    required this.totalDebit,
    required this.total,
    required this.page,
    required this.pages,
    required this.transactions,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      success: true,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      totalCredit: (json['totalCredit'] as num?)?.toDouble() ?? 0.0,
      totalDebit: (json['totalDebit'] as num?)?.toDouble() ?? 0.0,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
      transactions: json['transactions'] == null
          ? []
          : List<WalletTransactionModel>.from(
              json['transactions'].map((x) => WalletTransactionModel.fromJson(x)),
            ),
    );
  }

  factory TransactionHistoryModel.empty() => TransactionHistoryModel(
        success: false,
        balance: 0,
        totalCredit: 0,
        totalDebit: 0,
        total: 0,
        page: 1,
        pages: 1,
        transactions: [],
      );
}

// ─── OTP Response Model ───────────────────────────────────────────────────────
class OtpResponseModel {
  final bool success;
  final String message;
  final String txnRefNo;

  OtpResponseModel({
    required this.success,
    required this.message,
    required this.txnRefNo,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      success:   true,
      message:   json['message'] ?? '',
      txnRefNo:  json['txnRefNo'] ?? '',  // ✅ backend se aayega
    );
  }

  factory OtpResponseModel.error(String msg) => OtpResponseModel(
    success:  false,
    message:  msg,
    txnRefNo: '', 
  );
}

// ─── Add/Send Money Verify Response ──────────────────────────────────────────
class PaymentVerifyModel {
  final bool success;
  final String message;
  final double newBalance;
  final String txnId;
  final double amount;
  final String method;
  final String phoneNumber;
  final String status;
  final DateTime? createdAt;
  final String? recipientNumber;
  final String? note;
  

  PaymentVerifyModel({
    required this.success,
    required this.message,
    required this.newBalance,
    required this.txnId,
    required this.amount,
    required this.method,
    required this.phoneNumber,
    required this.status,
    this.createdAt,
    this.recipientNumber,
    this.note,

  });

factory PaymentVerifyModel.fromJson(Map<String, dynamic> json) {
  final txn = json['transaction'] ?? {};
  
  // ✅ success properly detect karo
  final bool isSuccess = json['message'] != null && 
      (json['message'].toString().toLowerCase().contains('success') ||
       json['message'].toString().toLowerCase().contains('credited') ||
       json['newBalance'] != null);

  return PaymentVerifyModel(
    success:     isSuccess,
    message:     json['message'] ?? '',
    newBalance:  (json['newBalance'] as num?)?.toDouble() ?? 0.0,
    txnId:       txn['txnId'] ?? json['txnId'] ?? '',
    amount:      (txn['amount'] as num?)?.toDouble() ?? 
                 (json['amount'] as num?)?.toDouble() ?? 0.0,
    method:      txn['method'] ?? json['method'] ?? '',
    phoneNumber: txn['phoneNumber'] ?? json['phoneNumber'] ?? '',
    status:      txn['status'] ?? json['status'] ?? 'success',
    createdAt:   txn['createdAt'] != null
        ? DateTime.tryParse(txn['createdAt'])
        : null,
    recipientNumber: txn['recipientNumber'],
    note:        txn['note'],
  );
}

factory PaymentVerifyModel.error(String msg) => PaymentVerifyModel(
  success:     false,
  message:     msg,
  newBalance:  0,
  txnId:       '',
  amount:      0,
  method:      '',
  phoneNumber: '',
  status:      'failed',
);
}

// ─── Saved Payment Method Model ───────────────────────────────────────────────
class SavedPaymentMethodModel {
  final String id;
  final String type; // "easypaisa" | "jazzcash"
  final String title;
  final String number;
  final bool isDefault;

  SavedPaymentMethodModel({
    required this.id,
    required this.type,
    required this.title,
    required this.number,
    required this.isDefault,
  });

  factory SavedPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return SavedPaymentMethodModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      number: json['number'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}

// ─── Payment Methods List Response ───────────────────────────────────────────
class PaymentMethodsModel {
  final bool success;
  final List<SavedPaymentMethodModel> methods;

  PaymentMethodsModel({required this.success, required this.methods});

  factory PaymentMethodsModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsModel(
      success: true,
      methods: json['methods'] == null
          ? []
          : List<SavedPaymentMethodModel>.from(
              json['methods'].map((x) => SavedPaymentMethodModel.fromJson(x)),
            ),
    );
  }

  factory PaymentMethodsModel.empty() =>
      PaymentMethodsModel(success: false, methods: []);
}