import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user_side/models/chatModel/chatModel.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/socketServices.dart';

class UserChatProvider extends ChangeNotifier {
  // ===== Inputs =====
  final String threadId;
  final String toType;
  final String toId;

  // ✅ CHANGED: Accept structured Map instead of String
  final Map<String, dynamic>? initialProductData;
  final String? initialMessage;

  UserChatProvider({
    required this.threadId,
    required this.toType,
    required this.toId,
    this.initialProductData, // ✅ Changed type
    this.initialMessage,
  });

  // ===== Optional UI scroll controller =====
  ScrollController? scrollController;

  // ===== State =====
  final List<ChatMessage> messages = [];
  bool isTyping = false;
  bool isLoadingHistory = true;

  // ===== Typing =====
  Timer? _typingTimer;
  String? _lastTypingValue;

  // ===== Dedupe / Pending =====
  final Map<String, String> _pendingClientMap = {};
  final Set<String> _processedMessageIds = {};
  final Set<String> _processedClientIds = {};
  final Map<String, DateTime> _recentMsgKeys = {};
  bool _listenersBound = false;

  bool _disposed = false;
  bool _productSent = false;

  /// ✅ Safe notify
  void _safeNotify() {
    if (_disposed) return;

    final phase = WidgetsBinding.instance.schedulerPhase;
    final isBuilding =
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;

    if (isBuilding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_disposed) return;
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  Future<void> init() async {
    final baseUrl = Global.imageUrl;
    final userId = await LocalStorage.getUserId();

    if (userId == null || userId.isEmpty) {
      isLoadingHistory = false;
      _safeNotify();
      return;
    }

    await _loadChatHistory(userId, baseUrl);

    final s = await SocketService().ensureConnected(
      baseUrl: baseUrl,
      auth: {'buyerId': userId},
    );

    if (s == null) {
      isLoadingHistory = false;
      _safeNotify();
      return;
    }

    SocketService().joinThread(threadId);
    _setupSocketListeners();

    markMessagesAsDelivered();
    markMessagesAsRead();

    isLoadingHistory = false;
    _safeNotify();

    // ✅ FIX: Thodi delay ke baad send karo taake socket fully ready ho
    Future.delayed(const Duration(milliseconds: 500), () {
      _sendProductIfProvided();
    });
  }

  /// ✅ FIXED: Direct access to structured data (NO PARSING)
  void _sendProductIfProvided() {
    if (_productSent) return;
    if (initialProductData == null || initialProductData!.isEmpty) return;

    // ✅ Pehle hi true kar do taake double send na ho
    _productSent = true;

    try {
      _sendProductCardMessage(
        productName: initialProductData!['productName'] ?? 'Product',
        brandName: initialProductData!['brandName'] ?? 'Brand',
        price: initialProductData!['productPrice'] ?? '0',
        description: initialProductData!['productDescription'],
        productImage: initialProductData!['productImage'] ?? '',
        additionalMessage: initialMessage,
      );
    } catch (e) {
      print('❌ Error sending product card: $e');
      _productSent = false; // ✅ Error pe reset karo taake retry ho sake
    }
  }

  /// ✅ IMPROVED: Send complete product card with image
  void _sendProductCardMessage({
    required String productName,
    required String brandName,
    required String price,
    String? description,
    String? productImage,
    String? additionalMessage,
  }) {
    final socket = SocketService().socket;

    // ✅ FIX: Socket ready nahi to retry karo
    if (socket == null || !socket.connected) {
      print('⚠️ Socket not ready, retrying in 1s...');
      Future.delayed(const Duration(seconds: 1), () {
        _sendProductCardMessage(
          productName: productName,
          brandName: brandName,
          price: price,
          description: description,
          productImage: productImage,
          additionalMessage: additionalMessage,
        );
      });
      return;
    }

    final now = DateTime.now();
    final tempId = "temp_${now.millisecondsSinceEpoch}";
    final clientId = now.millisecondsSinceEpoch.toString();
    final tempTs = now.toIso8601String();

    _pendingClientMap[clientId] = tempId;
    _processedMessageIds.add(tempId);

    final displayText = "📦 $productName";

    // ✅ Temp product card — UI mein foran dikhega
    final tempProductCard = ProductCard(
      productName: productName,
      brandName: brandName,
      productPrice: price,
      productDescription: description,
      productImage: productImage,
    );

    final tempMsg = ChatMessage(
      id: tempId,
      threadId: threadId,
      fromType: "buyer",
      text: displayText,
      timestamp: tempTs,
      productCard: tempProductCard,
    );

    _registerFingerprint(tempMsg);
    messages.insert(0, tempMsg);
    _safeNotify();

    socket.emitWithAck(
      "chat:send",
      {
        "threadId": threadId,
        "toType": toType,
        "toId": toId,
        "text": displayText,
        "clientId": clientId,
        "productCard": {
          "productName": productName,
          "productPrice": price,
          "productDescription": description ?? "",
          "productImage": productImage ?? "",
          "brandName": brandName,
          "sellerId": toId,
        },
      },
      ack: (resp) {
        print('🔍 ACK response: $resp');

        if (resp is! Map || resp["ok"] != true || resp["data"] == null) return;

        final serverMessage = ChatMessage.fromJson(
          Map<String, dynamic>.from(resp["data"]),
        );

        print('🔍 Server productCard: ${serverMessage.productCard}');

        _processedClientIds.add(clientId);

        final tId = _pendingClientMap.remove(clientId);
        if (tId == null) {
          if (serverMessage.id != null)
            _processedMessageIds.add(serverMessage.id!);
          _registerFingerprint(serverMessage);
          return;
        }

        final idx = messages.indexWhere((m) => m.id == tId);
        if (idx != -1) {
          // ✅ KEY FIX: Server productCard null ho to temp wala preserve karo
          final preservedProductCard =
              serverMessage.productCard ?? messages[idx].productCard;

          final finalMessage = ChatMessage(
            id: serverMessage.id,
            threadId: serverMessage.threadId,
            fromType: serverMessage.fromType,
            fromId: serverMessage.fromId,
            text: serverMessage.text,
            timestamp: serverMessage.timestamp,
            deliveredAt: serverMessage.deliveredAt,
            readAt: serverMessage.readAt,
            isExchangeRequest: serverMessage.isExchangeRequest,
            exchangeData: serverMessage.exchangeData,
            productCard: preservedProductCard, // ✅ Kabhi null nahi hoga
          );

          messages[idx] = finalMessage;
          _processedMessageIds.remove(tId);
          if (finalMessage.id != null)
            _processedMessageIds.add(finalMessage.id!);
          _registerFingerprint(finalMessage);
          _safeNotify();
        }
      },
    );

    // ✅ Additional message thodi delay ke baad
    if (additionalMessage != null && additionalMessage.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        sendMessage(additionalMessage);
      });
    }
  }

  Future<void> _loadChatHistory(String userId, String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/messages/$threadId?buyerId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messagesData = data['messages'] ?? [];

        // ✅ DEBUG: Server history check karo
        print('📦 Total messages from server: ${messagesData.length}');
        for (var msgData in messagesData) {
          if (msgData['productCard'] != null) {
            print('✅ ProductCard found in history: ${msgData['productCard']}');
          }
        }

        messages.clear();
        _processedMessageIds.clear();
        _processedClientIds.clear();
        _pendingClientMap.clear();
        _recentMsgKeys.clear();

        for (var msgData in messagesData.reversed) {
          final rawMap = Map<String, dynamic>.from(msgData);

          // ✅ FIX: productCard manually parse karo agar nested ho
          final msg = ChatMessage.fromJson(rawMap);

          // ✅ FIX: Agar productCard parse nahi hua lekin data exist karta hai
          final fixedMsg =
              (msg.productCard == null && rawMap['productCard'] != null)
              ? ChatMessage(
                  id: msg.id,
                  threadId: msg.threadId,
                  fromType: msg.fromType,
                  fromId: msg.fromId,
                  text: msg.text,
                  timestamp: msg.timestamp,
                  deliveredAt: msg.deliveredAt,
                  readAt: msg.readAt,
                  isExchangeRequest: msg.isExchangeRequest,
                  exchangeData: msg.exchangeData,
                  productCard: ProductCard.fromJson(
                    Map<String, dynamic>.from(rawMap['productCard']),
                  ),
                )
              : msg;

          messages.add(fixedMsg);
          if (fixedMsg.id != null) _processedMessageIds.add(fixedMsg.id!);
          _registerFingerprint(fixedMsg);
        }

        _safeNotify();
      } else {
        print('❌ History load failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ _loadChatHistory error: $e');
    }
  }

  // ==============================
  // Dedupe
  // ==============================
  String _buildMsgKey({
    required String? fromType,
    required String? text,
    required String? timestamp,
  }) {
    final t = (text ?? "").trim();

    String ts = (timestamp ?? "").toString();
    if (ts.length >= 19) ts = ts.substring(0, 19);

    return "${fromType ?? ""}|$t|$ts";
  }

  String _buildLooseKey({required String? fromType, required String? text}) {
    final t = (text ?? "").trim();
    return "${fromType ?? ""}|$t";
  }

  bool _isRecentDuplicate(String key, {int seconds = 6}) {
    final now = DateTime.now();
    _recentMsgKeys.removeWhere(
      (_, time) => now.difference(time).inSeconds > seconds,
    );

    final last = _recentMsgKeys[key];
    if (last != null && now.difference(last).inSeconds <= seconds) return true;

    _recentMsgKeys[key] = now;
    return false;
  }

  void _registerFingerprint(ChatMessage m) {
    final key = _buildMsgKey(
      fromType: m.fromType,
      text: m.text,
      timestamp: m.timestamp,
    );
    _recentMsgKeys[key] = DateTime.now();

    if (m.fromType == "buyer") {
      final loose = _buildLooseKey(fromType: m.fromType, text: m.text);
      _recentMsgKeys[loose] = DateTime.now();
    }
  }

  // ==============================
  // Socket Listeners
  // ==============================
  void _setupSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;

    final socket = SocketService().socket;
    if (socket == null) return;

    socket.off("chat:message");
    socket.off("exchange:new");
    socket.off("exchange:status");
    socket.off("chat:typing");
    socket.off("chat:status");
    socket.off("chat:status_bulk");

    socket.on("chat:message", (data) {
      if (data is! Map) return;

      final messageThreadId = data["threadId"]?.toString();
      if (messageThreadId != threadId) return;

      final messageId = (data["_id"] ?? data["id"])?.toString();
      final clientId = data["clientId"]?.toString();
      final fromType = data["fromType"]?.toString();

      final incomingTs = (data["timestamp"] ?? data["createdAt"])?.toString();
      final incomingText = data["text"]?.toString();

      final fpKey = _buildMsgKey(
        fromType: fromType,
        text: incomingText,
        timestamp: incomingTs,
      );
      if (_isRecentDuplicate(fpKey)) return;

      if (fromType == "buyer") {
        final loose = _buildLooseKey(fromType: fromType, text: incomingText);
        if (_isRecentDuplicate(loose)) return;
      }

      if (fromType == "buyer" &&
          clientId != null &&
          _processedClientIds.contains(clientId)) {
        return;
      }

      if (messageId != null && _processedMessageIds.contains(messageId)) {
        return;
      }

      // echoed own message: replace temp
      if (fromType == "buyer" &&
          clientId != null &&
          _pendingClientMap.containsKey(clientId)) {
        final tempId = _pendingClientMap.remove(clientId);
        final newMessage = ChatMessage.fromJson(
          Map<String, dynamic>.from(data),
        );

        final idx = tempId == null
            ? -1
            : messages.indexWhere((m) => m.id == tempId);

        if (idx != -1) {
          messages[idx] = newMessage;
          if (tempId != null) _processedMessageIds.remove(tempId);
          if (newMessage.id != null) _processedMessageIds.add(newMessage.id!);
        } else {
          if (newMessage.id != null &&
              !_processedMessageIds.contains(newMessage.id!)) {
            messages.insert(0, newMessage);
            _processedMessageIds.add(newMessage.id!);
          }
        }

        _processedClientIds.add(clientId);
        _registerFingerprint(newMessage);
        _safeNotify();
        return;
      }

      // normal insert
      final newMessage = ChatMessage.fromJson(Map<String, dynamic>.from(data));
      messages.insert(0, newMessage);
      if (newMessage.id != null) _processedMessageIds.add(newMessage.id!);
      if (fromType == "buyer" && clientId != null) {
        _processedClientIds.add(clientId);
      }
      _registerFingerprint(newMessage);

      if (newMessage.fromType != "buyer" && newMessage.id != null) {
        markSingleMessageDelivered(newMessage.id!);
        markSingleMessageRead(newMessage.id!);
      }

      _safeNotify();
    });

    socket.on("chat:typing", (data) {
      if (data is Map && data["threadId"] == threadId) {
        isTyping = (data["isTyping"] ?? false) == true;
        _safeNotify();
      }
    });

    socket.on("chat:status", (data) {
      if (data is! Map) return;
      final messageId = data["messageId"]?.toString();
      if (messageId == null) return;

      final deliveredAt = data["deliveredAt"]?.toString();
      final readAt = data["readAt"]?.toString();

      for (int i = 0; i < messages.length; i++) {
        if (messages[i].id == messageId) {
          messages[i] = ChatMessage(
            id: messages[i].id,
            threadId: messages[i].threadId,
            fromType: messages[i].fromType,
            fromId: messages[i].fromId,
            text: messages[i].text,
            timestamp: messages[i].timestamp,
            deliveredAt: deliveredAt,
            readAt: readAt,
            isExchangeRequest: messages[i].isExchangeRequest,
            exchangeData: messages[i].exchangeData,
            productCard: messages[i].productCard,
          );
          break;
        }
      }
      _safeNotify();
    });

    socket.on("chat:status_bulk", (data) {
      if (data is! Map) return;

      final List<dynamic> messageIds = data["messageIds"] ?? [];
      final readAt = data["readAt"]?.toString();
      if (messageIds.isEmpty || readAt == null) return;

      for (int i = 0; i < messages.length; i++) {
        if (messageIds.contains(messages[i].id)) {
          messages[i] = ChatMessage(
            id: messages[i].id,
            threadId: messages[i].threadId,
            fromType: messages[i].fromType,
            fromId: messages[i].fromId,
            text: messages[i].text,
            timestamp: messages[i].timestamp,
            deliveredAt: messages[i].deliveredAt ?? readAt,
            readAt: readAt,
            isExchangeRequest: messages[i].isExchangeRequest,
            exchangeData: messages[i].exchangeData,
            productCard: messages[i].productCard,
          );
        }
      }
      _safeNotify();
    });
  }

  // ==============================
  // Send Message
  // ==============================
  void sendMessage(String text) {
    final msg = text.trim();
    if (msg.isEmpty) return;

    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;

    final now = DateTime.now();
    final tempId = "temp_${now.millisecondsSinceEpoch}";
    final clientId = now.millisecondsSinceEpoch.toString();
    final tempTs = now.toIso8601String();

    _pendingClientMap[clientId] = tempId;
    _processedMessageIds.add(tempId);

    final tempMsg = ChatMessage(
      id: tempId,
      threadId: threadId,
      fromType: "buyer",
      text: msg,
      timestamp: tempTs,
    );

    _registerFingerprint(tempMsg);
    messages.insert(0, tempMsg);
    _safeNotify();

    onTyping("");

    socket.emitWithAck(
      "chat:send",
      {
        "threadId": threadId,
        "toType": toType,
        "toId": toId,
        "text": msg,
        "clientId": clientId,
      },
      ack: (resp) {
        if (resp is! Map || resp["ok"] != true || resp["data"] == null) return;

        final serverMessage = ChatMessage.fromJson(
          Map<String, dynamic>.from(resp["data"]),
        );

        _processedClientIds.add(clientId);

        final tId = _pendingClientMap.remove(clientId);
        if (tId == null) {
          if (serverMessage.id != null)
            _processedMessageIds.add(serverMessage.id!);
          _registerFingerprint(serverMessage);
          return;
        }

        final idx = messages.indexWhere((m) => m.id == tId);
        if (idx != -1) {
          messages[idx] = serverMessage;
          _processedMessageIds.remove(tId);
          if (serverMessage.id != null)
            _processedMessageIds.add(serverMessage.id!);
          _registerFingerprint(serverMessage);
          _safeNotify();
        } else {
          if (serverMessage.id != null)
            _processedMessageIds.add(serverMessage.id!);
          _registerFingerprint(serverMessage);
        }
      },
    );
  }

  // ==============================
  // Typing
  // ==============================
  void onTyping(String value) {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;

    _typingTimer?.cancel();

    if (value.isNotEmpty) {
      if (_lastTypingValue != value) {
        socket.emit("chat:typing", {"threadId": threadId, "isTyping": true});
        _lastTypingValue = value;
      }

      _typingTimer = Timer(const Duration(seconds: 2), () {
        socket.emit("chat:typing", {"threadId": threadId, "isTyping": false});
        _lastTypingValue = null;
      });
    } else {
      socket.emit("chat:typing", {"threadId": threadId, "isTyping": false});
      _lastTypingValue = null;
    }
  }

  // ==============================
  // Delivery / Read
  // ==============================
  void markMessagesAsDelivered() {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;

    final ids = messages
        .where(
          (m) => m.fromType != "buyer" && m.deliveredAt == null && m.id != null,
        )
        .map((m) => m.id!)
        .toList();

    for (final id in ids) {
      socket.emit("chat:delivered", {"messageId": id});
    }
  }

  void markSingleMessageDelivered(String messageId) {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;
    socket.emit("chat:delivered", {"messageId": messageId});
  }

  void markMessagesAsRead() {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;

    final ids = messages
        .where((m) => m.fromType != "buyer" && m.readAt == null && m.id != null)
        .map((m) => m.id!)
        .toList();

    if (ids.isNotEmpty) {
      socket.emit("chat:read", {"threadId": threadId, "messageIds": ids});
    }
  }

  void markSingleMessageRead(String messageId) {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;
    socket.emit("chat:read", {
      "threadId": threadId,
      "messageIds": [messageId],
    });
  }

  // ==============================
  // Helpers
  // ==============================
  String formatTime(String? timestamp) {
    if (timestamp == null) return "";
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) return DateFormat('HH:mm').format(date);
      if (diff.inDays == 1) return "Yesterday";
      if (diff.inDays < 7) return DateFormat('EEEE').format(date);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return "";
    }
  }

  String imgUrl(String path) {
    if (path.startsWith("http://") || path.startsWith("https://")) return path;
    return "${Global.imageUrl}/$path";
  }

  Future<void> downloadExchangeSlip(String exchangeId) async {
    final buyerId = await LocalStorage.getUserId();
    if (buyerId == null || buyerId.isEmpty) return;

    final url = "${Global.getExchangePdf}/$exchangeId/pdf?buyerId=$buyerId";
    final resp = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/pdf"},
    );

    if (resp.statusCode != 200) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/exchange_$exchangeId.pdf");
    await file.writeAsBytes(resp.bodyBytes, flush: true);

    await OpenFilex.open(file.path);
  }

  @override
  void dispose() {
    _disposed = true;
    _typingTimer?.cancel();
    SocketService().leaveThread(threadId);
    super.dispose();
  }
}
