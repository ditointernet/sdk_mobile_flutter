import 'package:dito_sdk/notification/notification_entity.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessageClickedEvent {
  NotificationEntity message;

  MessageClickedEvent(this.message);
}

class NotificationEvents {
  EventBus eventBus = EventBus();

  static final NotificationEvents _instance = NotificationEvents._internal();

  factory NotificationEvents() {
    return _instance;
  }

  EventBus get stream => eventBus;

  NotificationEvents._internal();
}
