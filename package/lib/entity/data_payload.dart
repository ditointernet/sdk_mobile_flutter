class Details {
  final String? link;
  final String message;
  final String title;

  Details(this.link, this.title, this.message);

  factory Details.fromJson(dynamic json) {
    assert(json is Map);
    return Details(json["link"], json["title"], json["message"]);
  }

  Map<String, dynamic> toJson() => {
        'link': link,
        'message': message,
        'title': title,
      };
}

class DataPayload {
  final String reference;
  final String identifier;
  final String notification;
  final String notification_log_id;
  final Details details;

  DataPayload(this.reference, this.identifier, this.notification,
      this.notification_log_id, this.details);

  factory DataPayload.fromJson(dynamic json) {
    assert(json is Map);

    return DataPayload(
        json["reference"],
        json["identifier"],
        json["notification"],
        json["notification_log_id"],
        Details.fromJson(json["details"]));
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'identifier': identifier,
        'notification': notification,
        'notification_log_id': notification_log_id,
        'details': details.toJson(),
      };
}
