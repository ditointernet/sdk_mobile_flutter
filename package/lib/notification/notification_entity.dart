import 'dart:io';

class Details {
  final String? link;
  final String? title;
  final String message;
  String? image;

  Details(this.title, this.message, this.link, this.image);

  factory Details.fromJson(dynamic json) {
    assert(json is Map);
    return Details(json["title"], json["message"], json["link"], json["image"]);
  }

  Map<String, dynamic> toJson() =>
      {'link': link, 'message': message, 'title': title, 'image': image};
}

class DataPayload {
  final String? reference;
  final String? identifier;
  final String? notification;
  final String? notification_log_id;
  final Details details;

  DataPayload(this.reference, this.identifier, this.notification,
      this.notification_log_id, this.details);

  factory DataPayload.fromMap(dynamic json) {
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

    final Details details = Details(title, message, link, image);

    return DataPayload(
      json["data"]["reference"],
      json["data"]["user_id"],
      json["data"]["notification"],
      json["data"]["notification_log_id"],
      details,
    );
  }

  factory DataPayload.fromPayload(dynamic json) {
    assert(json is Map);

    return DataPayload(
      json["reference"],
      json["identifier"],
      json["notification_log_id"],
      json["notification"],
      Details.fromJson(json["details"]),
    );
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'identifier': identifier,
        'notification': notification,
        'notification_log_id': notification_log_id,
        'details': details.toJson()
      };
}

class NotificationEntity {
  int id;
  String title;
  String body;
  String? notificationId;
  String? image;

  DataPayload? payload;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.notificationId,
    this.image,
    this.payload,
  });
}
