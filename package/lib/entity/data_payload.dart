class DataPayload {
  final String reference;
  final String user_id;
  final String notification;
  final String log_id;
  final String notification_name;
  final String device_type;
  final String title;
  final String message;
  final String link;
  final String icon;
  final String channel;

  DataPayload(
      this.reference,
      this.user_id,
      this.notification,
      this.log_id,
      this.notification_name,
      this.device_type,
      this.title,
      this.message,
      this.link,
      this.icon,
      this.channel);

  factory DataPayload.fromJson(dynamic json) {
    assert(json is Map);

    return DataPayload(
        json["reference"] ?? "",
        json["user_id"] ?? "",
        json["notification"] ?? "",
        json["log_id"] ?? "",
        json["notification_name"] ?? "",
        json["device_type"] ?? "",
        json["title"] ?? "",
        json["message"] ?? "",
        json["link"] ?? "",
        json["icon"] ?? "",
        json["channel"] ?? "");
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'user_id': user_id,
        'notification': notification,
        'log_id': log_id,
        'notification_name': notification_name,
        'device_type': device_type,
        'title': title,
        'message': message,
        'link': link,
        'icon': icon,
        'channel': channel,
      };
}
