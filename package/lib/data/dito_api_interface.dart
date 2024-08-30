import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../event/event_entity.dart';
import '../user/user_entity.dart';
import '../notification/notification_interface.dart';
import '../user/user_interface.dart';
import '../utils/sha1.dart';
import '../proto/api.pb.dart' as api;
import '../proto/google/protobuf/timestamp.pb.dart';

const url = 'http://10.0.2.2:8080/connect.sdk_api.v1.SDKService/Activity';

class DitoApiInterface {
  String? _apiKey;
  String? _secretKey;

  static final DitoApiInterface _instance = DitoApiInterface._internal();

  factory DitoApiInterface() {
    return _instance;
  }

  DitoApiInterface._internal();

  void setKeys(String apiKey, String secretKey) {
    _instance._apiKey = apiKey;
    _instance._secretKey = convertToSHA1(secretKey);
  }

  void _checkConfiguration() {
    if (_apiKey == null || _secretKey == null) {
      throw Exception(
          'API key and Secret Key must be initialized before using. Please call the initialize() method first.');
    }
  }

  Future<api.DeviceInfo> getDeviceToken() async {
    NotificationInterface notificationInterface = NotificationInterface();
    final token = await notificationInterface.getFirebaseToken();

    return api.DeviceInfo()
      ..os = api.DeviceOs.DEVICE_OS_ANDROID
      ..token = token!;
  }

  Future<api.SDKInfo> getSDKInfo() async {
    return api.SDKInfo()
      ..version = '2.0.0'
      ..build = '1'
      ..lang = 'flutter';
  }

  Future<api.AppInfo> getAppInfo() async {
    return api.AppInfo()
      ..id = 'app-id'
      ..build = 'app-build'
      ..platform = 'android'
      ..version = '1.0.0';
  }

  api.UserInfo getUserInfo() {
    UserInterface userInterface = UserInterface();
    final user = userInterface.data;

    if (user.isNotValid) {
      throw Exception(
          'User registration is required. Please call the identify() method first.');
    }

    return api.UserInfo()
      ..ditoId = user.id ?? ""
      ..email = user.email ?? ""
      ..name = user.name ?? ""
      ..birthday = user.birthday ?? ""
      ..gender = user.gender ?? ""
      ..address = (api.UserInfo_Address()
        ..city = user.address?.city ?? ""
        ..country = user.address?.country ?? ""
        ..postalCode = user.address?.postalCode ?? ""
        ..state = user.address?.state ?? ""
        ..street = user.address?.street ?? "");
  }

  Future<bool> _apiCall(List<int> serializedRequest) async {
    _checkConfiguration();

    final headers = {
      'Content-Type': 'application/proto',
      'platform_api_key': _apiKey!,
      'sha1_signature': _secretKey!,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: serializedRequest,
    );

    if (response.statusCode == 200) {
      final responseProto = api.Response.fromBuffer(response.bodyBytes);
      for (var responseData in responseProto.response) {
        if (responseData.hasError()) {
          final activityId = responseData.id;
          final error = responseData.error;

          if (kDebugMode) {
            print('Activity: $activityId');
            print('Error Code: ${error.code}');
            print('Error Message: ${error.message}');
            switch (error.code) {
              case api.ErrorCode.ERROR_INVALID_REQUEST:
                throw('Invalid request format.');
              case api.ErrorCode.ERROR_UNAUTHORIZED:
                throw('Unauthorized access.');
              case api.ErrorCode.ERROR_NOT_FOUND:
                throw('Resource not found.');
              case api.ErrorCode.ERROR_INTERNAL:
                throw('Internal server error.');
              case api.ErrorCode.ERROR_NOT_IMPLEMENTED:
                throw('Feature not implemented.');
              default:
                throw('Unknown error occurred.');
            }
          }
        }
      }

      return true;
    }

    throw('Unknown error occurred.');
  }

  Future<api.Request> createRequest() async {
    final device = await getDeviceToken();
    final sdk = await getSDKInfo();
    final app = await getAppInfo();
    final user = getUserInfo();

    return api.Request()
      ..user = user
      ..device = device
      ..sdk = sdk
      ..app = app;
  }

  Future<bool> identify(UserEntity user) async {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    final activities = [
      api.Activity()
        ..timestamp = now
        ..id = uuid.v4()
        ..type = api.ActivityType.ACTIVITY_IDENTIFY
        ..userData = api.Activity_UserDataActivity(),
    ];

    final request = await createRequest()
      ..activities.addAll(activities);

    List<int> serializedRequest = request.writeToBuffer();
    return await _apiCall(serializedRequest);
  }

  Future<bool> trackEvent(EventEntity event) async {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    final activities = [
      api.Activity()
        ..timestamp = now
        ..id = uuid.v4()
        ..type = api.ActivityType.ACTIVITY_TRACK
        ..track = (api.Activity_TrackActivity()
          ..event = event.eventName
          ..revenue = event.revenue ?? 0
          ..currency = event.currency ?? 'BRL'
          ..utmSource = 'source'
          ..data.addAll(event.customData
                  ?.map((key, value) => MapEntry(key, value.toString())) ??
              {}))
    ];

    final request = await createRequest()
      ..activities.addAll(activities);

    List<int> serializedRequest = request.writeToBuffer();
    return await _apiCall(serializedRequest);
  }

  Future<bool> openNotification(
      String notificationId, String identifier, String reference) async {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    final activities = [
      api.Activity()
        ..timestamp = now
        ..id = uuid.v4()
        ..type = api.ActivityType.ACTIVITY_TRACK
        ..trackPushClick = (api.Activity_TrackPushClickActivity()
          ..notification = (api.NotificationInfo()
            ..notificationId = notificationId
            ..dispatchId = identifier)
          ..utmSource = 'source')
    ];

    final request = await createRequest()
      ..activities.addAll(activities)
      ..user.ditoId = reference;

    List<int> serializedRequest = request.writeToBuffer();
    return await _apiCall(serializedRequest);
  }

  Future<bool> receiveNotification(
      String notificationId, String identifier, String reference) async {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    final activities = [
      api.Activity()
        ..timestamp = now
        ..id = uuid.v4()
        ..type = api.ActivityType.ACTIVITY_TRACK
        ..trackPushReceipt = (api.Activity_TrackPushReceiptActivity()
          ..notification = (api.NotificationInfo()
            ..notificationId = notificationId
            ..dispatchId = identifier)
          ..utmSource = 'source')
    ];

    final request = await createRequest()
      ..activities.addAll(activities)
      ..user.ditoId = reference;

    List<int> serializedRequest = request.writeToBuffer();
    return await _apiCall(serializedRequest);
  }

  Future<bool> registryToken(String token) async {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    final activities = [
      api.Activity()
        ..timestamp = now
        ..id = uuid.v4()
        ..type = api.ActivityType.ACTIVITY_REGISTER
        ..tokenRegister = (api.Activity_TokenRegisterActivity()
          ..token = token
          ..provider = api.PushProvider.PROVIDER_FCM)
    ];

    final request = await createRequest()
      ..activities.addAll(activities);

    List<int> serializedRequest = request.writeToBuffer();
    return await _apiCall(serializedRequest);
  }

  Future<bool> removeToken(String token) async {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    final activities = [
      api.Activity()
        ..timestamp = now
        ..id = uuid.v4()
        ..type = api.ActivityType.ACTIVITY_REGISTER
        ..tokenUnregister = (api.Activity_TokenUnregisterActivity()
          ..token = token
          ..provider = api.PushProvider.PROVIDER_FCM),
    ];

    final request = await createRequest()
      ..activities.addAll(activities);

    List<int> serializedRequest = request.writeToBuffer();
    return await _apiCall(serializedRequest);
  }
}
