class BuyerNotificationResponse {
  String? message;
  int? unreadCount;
  List<BuyerNotificationItem>? notifications;

  BuyerNotificationResponse({this.message, this.unreadCount, this.notifications});

  BuyerNotificationResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    unreadCount = json['unreadCount'];
    if (json['notifications'] != null) {
      notifications = <BuyerNotificationItem>[];
      json['notifications'].forEach((v) {
        notifications!.add(BuyerNotificationItem.fromJson(v));
      });
    }
  }
}

class BuyerNotificationItem {
  String? id;
  String? title;
  String? body;
  String? type;
  bool? isRead;
  String? image;
  String? accentColor;
  Map<String, dynamic>? data;
  String? createdAt;

  BuyerNotificationItem({
    this.id,
    this.title,
    this.body,
    this.type,
    this.isRead,
    this.image,
    this.accentColor,
    this.data,
    this.createdAt,
  });

  BuyerNotificationItem.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    body = json['body'];
    type = json['type'];
    isRead = json['isRead'];
    image = json['image'];
    accentColor = json['accentColor'];
    data = (json['data'] is Map<String, dynamic>) ? json['data'] : {};
    createdAt = json['createdAt'];
  }
}
