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
  final String identifier;
  final String? reference;
  final String? contactId;
  final String? notificationLogId;
  final DetailsEntity? details;
  final String? createdAt;

  NotificationEntity({
    required this.identifier,
    required this.notification,
    this.reference,
    this.contactId,
    this.notificationLogId,
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

    return NotificationEntity(
				contactId: json["messageId"],
        reference: json["data"]["reference"],
        notification: json["data"]["notification"],
        notificationLogId: json["data"]["notification_log_id"],
        identifier: json["data"]["user_id"],
        createdAt: json["data"]["createdAt"],
        details: details);
  }

  factory NotificationEntity.fromPayload(dynamic json) {
    assert(json is Map);

    return NotificationEntity(
      reference: json["reference"],
      contactId: json["contactId"],
      notification: json["notification"],
      notificationLogId: json["notificationLogId"],
      identifier: json["identifier"],
      createdAt: json["createdAt"],
      details: DetailsEntity.fromJson(json["details"]),
    );
  }

  Map<String, dynamic> toJson() => {
				'contactId': contactId,
        'reference': reference,
        'identifier': identifier,
        'notification': notification,
        'notificationLogId': notificationLogId,
        'details': details,
        'createdAt': createdAt,
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
