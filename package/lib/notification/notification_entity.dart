import 'dart:io';

class DetailsEntity {
  final String? link;
  final String? title;
  final String message;
  String? image;

  DetailsEntity(this.title, this.message, this.link, this.image);

  factory DetailsEntity.fromJson(dynamic json) {
    assert(json is Map);
    return DetailsEntity(
        json["title"], json["message"], json["link"], json["image"]);
  }

  Map<String, dynamic> toJson() =>
      {'link': link, 'message': message, 'title': title, 'image': image};
}

class NotificationEntity {
  final String notification;
  final String? notificationLogId;
  final String? contactId;
  final String? reference;
  final String? userId;
  final String? name;
  final DetailsEntity? details;
  final String? createdAt;

  NotificationEntity({
    required this.notification,
    this.notificationLogId,
    this.contactId,
    this.reference,
    this.userId,
    this.name,
    this.details,
    this.createdAt,
  });

  factory NotificationEntity.fromMap(dynamic json) {
    final String? image;
    assert(json is Map);

    if (Platform.isAndroid) {
      image = json["notification"]?["android"]?["imageUrl"];
    } else {
      image = json["notification"]?["apple"]?["imageUrl"];
    }

    final String title =
        json["notification"]?["title"] ?? json["data"]["title"];
    final String message =
        json["notification"]?["body"] ?? json["data"]["message"];
    final String link = json["data"]["link"];

    final DetailsEntity details = DetailsEntity(title, message, link, image);

    DateTime localDateTime = DateTime.now();
    DateTime utcDateTime = localDateTime.toUtc();

    return NotificationEntity(
        notification: json["data"]["notification"],
        notificationLogId: json["data"]["log_id"],
        contactId: json["messageId"],
        reference: json["data"]["reference"],
        userId: json["data"]["user_id"],
        name: json["data"]["name"],
        createdAt: utcDateTime.toIso8601String(),
        details: details);
  }

  factory NotificationEntity.fromPayload(dynamic json) {
    assert(json is Map);

    return NotificationEntity(
      notification: json["notification"],
      notificationLogId: json["notificationLogId"],
      contactId: json["contactId"],
      reference: json["reference"],
      userId: json["userId"],
      name: json["name"],
      createdAt: json["createdAt"],
      details: DetailsEntity.fromJson(json["details"]),
    );
  }

  Map<String, dynamic> toJson() => {
        'notification': notification,
        'notificationLogId': notificationLogId,
        'contactId': contactId,
        'reference': reference,
        'userId': userId,
        'name': name,
        'createdAt': createdAt,
        'details': details,
      };
}

class NotificationDisplayEntity {
  int id;
  String title;
  String body;
  String? notificationId;
  String? image;
  Map<String, dynamic>? data;

  NotificationDisplayEntity({
    required this.id,
    required this.title,
    required this.body,
    this.notificationId,
    this.image,
    this.data,
  });
}
