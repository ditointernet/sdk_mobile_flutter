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
  final String reference;
  final String notification;
  final String notification_log_id;
  final Details details;

  DataPayload(this.reference, this.notification, this.notification_log_id,
      this.details);

  factory DataPayload.fromJson(dynamic json) {
    assert(json is Map);

    return DataPayload(json["reference"], json["notification"],
        json["notification_log_id"], Details.fromJson(json["details"]));
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'notification': notification,
        'notification_log_id': notification_log_id,
        'details': details.toJson(),
      };
}
