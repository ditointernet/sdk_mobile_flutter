library dito_sdk;

import 'package:dito_sdk/user/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'database.dart';
import 'entity/event.dart';
import 'entity/user.dart';
import 'services/notification_service.dart';
import 'data/dito_api.dart';

class DitoSDK {
  final _userInterface = UserInterface();
  User _user = User();
  late NotificationService _notificationService;
  Constants constants = Constants();

  late DitoApi ditoApi;

  static final DitoSDK _instance = DitoSDK._internal();

  factory DitoSDK() {
    return _instance;
  }

  DitoSDK._internal();

  UserInterface get user => _userInterface;

  NotificationService notificationService() {
    return _notificationService;
  }

  void initialize({required String apiKey, required String secretKey}) async {
    _notificationService = NotificationService(_instance);
    ditoApi = DitoApi(apiKey, secretKey);
  }

  Future<void> initializePushNotificationService() async {
    await Firebase.initializeApp();
    await _notificationService.initialize();

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _notificationService.handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp
        .listen(_notificationService.handleMessage);
  }

  Future<void> _verifyPendingEvents() async {
    final database = LocalDatabase.instance;
    final events = await database.getEvents();

    if (events.isNotEmpty) {
      for (final event in events) {
        await _postEvent(event);
      }
      database.deleteEvents();
    }
  }

  @Deprecated('Use user.set(User user) to set all user information\'s')
  Future<void> setUserId(String userId) async {
    _verifyPendingEvents();
  }

  @Deprecated('Use user.set(User user) to set all user information\'s')
  void identify({
    required String userID,
    String? cpf,
    String? name,
    String? email,
    String? gender,
    String? birthday,
    String? location,
    Map<String, String>? customData,
  }) {
    _userInterface.set(UserEntity(
        userID: userID,
        cpf: cpf,
        name: name,
        email: email,
        gender: gender,
        birthday: birthday,
        location: location,
        customData: customData));
  }

  @Deprecated('Use user.set(User user) to set all user information\'s')
  Future<void> setUser(User user) async {
    _userInterface.set(user);
  }

  @Deprecated(
      'Use user.identify(User user) to set all user information\'s and create a login event on platform')
  Future<http.Response> identifyUser() async {
    _checkConfiguration();

    final result = await _userInterface.identify(null);
    if (result) return http.Response('', 200);
    return http.Response('', 500);
  }

  Future<http.Response> _postEvent(Event event) async {
    _checkConfiguration();

    final body = {
      'id_type': 'id',
      'network_name': 'pt',
      'event': jsonEncode(event.toJson())
    };

    final url = Domain(Endpoint.events.replace(_userInterface.id!)).spited;
    final uri = Uri.https(url[0], url[1], _assign);

    body.addAll(_assign);
    return await Api().post(url: uri, body: body);
  }

  Future<http.Response> trackEvent({
    required String eventName,
    double? revenue,
    Map<String, String>? customData,
  }) async {
    DateTime localDateTime = DateTime.now();
    DateTime utcDateTime = localDateTime.toUtc();
    String eventMoment = utcDateTime.toIso8601String();

    final event = Event(
        eventName: eventName,
        eventMoment: eventMoment,
        customData: customData,
        revenue: revenue);

    if (_userInterface.isNotValid) {
      final database = LocalDatabase.instance;
      await database.createEvent(event);
      return http.Response("", 200);
    }

    return await ditoApi.trackEvent(event, _user);
  }

  Future<http.Response> registryMobileToken({required String token}) async {
    return await ditoApi.registryMobileToken(token, _user);
  }

  Future<http.Response> removeMobileToken({required String token}) async {
    return await ditoApi.removeMobileToken(token, _user);
  }

  Future<http.Response> openNotification(
      {required String notificationId,
      required String identifier,
      required String reference}) async {
    return await ditoApi.openNotification(
        notificationId, identifier, reference);
  }
}
