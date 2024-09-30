import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../api/dito_api_interface.dart';
import '../event/event_dao.dart';
import '../user/user_repository.dart';
import 'notification_entity.dart';

class NotificationRepository {
  final ApiInterface _api = ApiInterface();
  final UserRepository _userRepository = UserRepository();
  final _database = EventDAO();

  /// The broadcast stream for received notifications
  final StreamController<NotificationEntity> didReceiveLocalNotificationStream =
      StreamController<NotificationEntity>.broadcast();

  /// The broadcast stream for selected notifications
  final StreamController<RemoteMessage> selectNotificationStream =
      StreamController<RemoteMessage>.broadcast();

  /// This method send a notify click on push event to Dito
  ///
  /// [notification] - Notification object.
  Future<bool> click(NotificationEntity notification) async {
    final activity = ApiActivities().notificationClick(notification);

    if (_userRepository.data.isNotValid) {
      return await _database.create(EventsNames.click, activity.id,
          notification: notification);
    }

    final result = await _api.createRequest([activity]).call();

    if (result >= 400 && result < 500) {
      await _database.create(EventsNames.click, activity.id,
          notification: notification);

      return false;
    }

    return true;
  }

  /// This method send a notify received push event to Dito
  ///
  /// [notification] - Notification object.
  Future<bool> received(NotificationEntity notification) async {
    final activity = ApiActivities().notificationReceived(notification);

    if (_userRepository.data.isNotValid) {
      return await _database.create(EventsNames.received, activity.id,
          notification: notification);
    }

    final result = await _api.createRequest([activity]).call();

    if (result >= 400 && result < 500) {
      await _database.create(EventsNames.received, activity.id,
          notification: notification);

      return false;
    }

    return true;
  }
}
