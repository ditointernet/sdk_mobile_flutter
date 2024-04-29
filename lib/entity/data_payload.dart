class Details {
  final String? link;
  final String message;

  Details(this.link, this.message);

  factory Details.fromJson(dynamic json) {
    assert(json is Map);
    return Details(json["link"], json["message"]);
  }

  Map<String, dynamic> toJson() => {
        'link': link,
        'message': message,
      };
}

class DataPayload {
  final int reference;
  final int notification;
  final int notification_log_id;
  final Details details;

  DataPayload(this.reference, this.notification, this.notification_log_id,
      this.details);

  factory DataPayload.fromJson(dynamic json) {
    assert(json is Map);

    final reference = json["reference"] is int
        ? json["reference"]
        : int.parse(json["reference"]);
    final notification = json["notification"] is int
        ? json["notification"]
        : int.parse(json["notification"]);
    final notificationLogId = json["notification_log_id"] is int
        ? json["notification_log_id"]
        : int.parse(json["notification_log_id"]);

    return DataPayload(reference, notification, notificationLogId,
        Details.fromJson(json["details"]));
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'notification': notification,
        'notification_log_id': notification_log_id,
        'details': details.toJson(),
      };
}
