import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../event/event_entity.dart';
import '../event/navigation_entity.dart';
import '../notification/notification_entity.dart';
import '../proto/google/protobuf/timestamp.pb.dart';
import '../proto/sdkapi/v1/api.pb.dart' as rpcAPI;
import '../user/user_interface.dart';
import '../utils/sha1.dart';

const url = 'https://sdk.dito.com.br/connect.sdk_api.v1.SDKService/Activity';

class AppInfoEntity {
  String? build;
  String? version;
  String? id;
  String? platform;
  String? sdkVersion;
  String? sdkBuild;
  String? sdkLang;
}

final class AppInfo extends AppInfoEntity {
  AppInfo._internal();

  static final appInfo = AppInfo._internal();

  factory AppInfo() => appInfo;
}

class ApiActivities {
  final UserInterface _userInterface = UserInterface();
  final AppInfo _appInfo = AppInfo();

  Timestamp _parseToTimestamp(String? time) {
    return time != null
        ? Timestamp.fromDateTime(DateTime.parse(time))
        : Timestamp.fromDateTime(DateTime.now());
  }

  rpcAPI.DeviceOs _getPlatform() {
    if (Platform.isIOS) {
      return rpcAPI.DeviceOs.DEVICE_OS_IOS;
    } else {
      return rpcAPI.DeviceOs.DEVICE_OS_ANDROID;
    }
  }

  rpcAPI.DeviceInfo get deviceToken => rpcAPI.DeviceInfo()
    ..os = _getPlatform()
    ..token = _userInterface.data.token!;

  rpcAPI.SDKInfo get sdkInfo => rpcAPI.SDKInfo()
    ..version = _appInfo.sdkVersion!
    ..build = _appInfo.build!
    ..lang = _appInfo.sdkLang!;

  rpcAPI.AppInfo get appInfo => rpcAPI.AppInfo()
    ..id = _appInfo.id!
    ..build = _appInfo.build!
    ..platform = _appInfo.platform!
    ..version = _appInfo.version!;

  rpcAPI.UserInfo get userInfo {
    final user = rpcAPI.UserInfo();

    if (_userInterface.data.email != null &&
        _userInterface.data.email!.isNotEmpty) {
      user.email = _userInterface.data.email!;
    }

    if (_userInterface.data.id != null && _userInterface.data.id!.isNotEmpty) {
      user.ditoId = _userInterface.data.id!;
    }

    if (_userInterface.data.name != null &&
        _userInterface.data.name!.isNotEmpty) {
      user.name = _userInterface.data.name!;
    }

    if (_userInterface.data.birthday != null &&
        _userInterface.data.birthday!.isNotEmpty) {
      user.birthday = _userInterface.data.birthday!;
    }

    if (_userInterface.data.phone != null &&
        _userInterface.data.phone!.isNotEmpty) {
      user.phone = _userInterface.data.phone!;
    }

    if (_userInterface.data.gender != null &&
        _userInterface.data.gender!.isNotEmpty) {
      user.gender = _userInterface.data.gender!;
    }

    if (_userInterface.data.cpf != null &&
        _userInterface.data.cpf!.isNotEmpty) {
      user.customData['cpf'] = rpcAPI.UserInfo_CustomData(
          format: 'string', value: _userInterface.data.cpf);
    }

    if (_userInterface.data.customData != null &&
        _userInterface.data.customData!.isNotEmpty) {
      user.customData.addAll(_userInterface.data.customData!.map((key, value) {
        final customDataValue =
            rpcAPI.UserInfo_CustomData(format: 'string', value: value);
        return MapEntry(key, customDataValue);
      }));
    }

    final addressData = _userInterface.data.address;
    if (addressData != null) {
      final hasAddress = [
        addressData.city,
        addressData.country,
        addressData.postalCode,
        addressData.state,
        addressData.street
      ].any((field) => field != null && field.isNotEmpty);

      if (hasAddress) {
        user.address = rpcAPI.UserInfo_Address();

        if (_userInterface.data.address?.city != null &&
            _userInterface.data.address!.city!.isNotEmpty) {
          user.address.city = _userInterface.data.address!.city!;
        }

        if (_userInterface.data.address?.country != null &&
            _userInterface.data.address!.country!.isNotEmpty) {
          user.address.country = _userInterface.data.address!.country!;
        }

        if (_userInterface.data.address?.postalCode != null &&
            _userInterface.data.address!.postalCode!.isNotEmpty) {
          user.address.postalCode = _userInterface.data.address!.postalCode!;
        }

        if (_userInterface.data.address?.state != null &&
            _userInterface.data.address!.state!.isNotEmpty) {
          user.address.state = _userInterface.data.address!.state!;
        }

        if (_userInterface.data.address?.street != null &&
            _userInterface.data.address!.street!.isNotEmpty) {
          user.address.street = _userInterface.data.address!.street!;
        }
      }
    }
    return user;
  }

  rpcAPI.Activity identify({String? uuid, String? time}) {
    final generatedUuid = uuid ?? Uuid().v4();
    final generatedTime = _parseToTimestamp(time);

    return rpcAPI.Activity()
      ..timestamp = generatedTime
      ..id = generatedUuid
      ..type = rpcAPI.ActivityType.ACTIVITY_IDENTIFY
      ..userData = rpcAPI.Activity_UserDataActivity();
  }

  rpcAPI.Activity login({String? uuid, String? time}) {
    final generatedUuid = uuid ?? Uuid().v4();
    final generatedTime = _parseToTimestamp(time);

    return rpcAPI.Activity()
      ..timestamp = generatedTime
      ..id = generatedUuid
      ..type = rpcAPI.ActivityType.ACTIVITY_TRACK
      ..userLogin = (rpcAPI.Activity_UserLoginActivity()..utmSource = 'source');
  }

  rpcAPI.Activity trackEvent(EventEntity event, {String? uuid, String? time}) {
    final generatedUuid = uuid ?? Uuid().v4();
    final generatedTime = _parseToTimestamp(time);

    return rpcAPI.Activity()
      ..timestamp = generatedTime
      ..id = generatedUuid
      ..type = rpcAPI.ActivityType.ACTIVITY_TRACK
      ..track = (rpcAPI.Activity_TrackActivity()
        ..event = event.action
        ..revenue = event.revenue ?? 0
        ..currency = event.currency ?? 'BRL'
        ..utmSource = 'source'
        ..data.addAll(event.customData
                ?.map((key, value) => MapEntry(key, value.toString())) ??
            {}));
  }

  rpcAPI.Activity trackNavigation(NavigationEntity navigation,
      {String? uuid, String? time}) {
    final generatedUuid = uuid ?? Uuid().v4();
    final generatedTime = _parseToTimestamp(time);

    return rpcAPI.Activity()
      ..timestamp = generatedTime
      ..id = generatedUuid
      ..type = rpcAPI.ActivityType.ACTIVITY_TRACK
      ..trackNavigation = (rpcAPI.Activity_TrackNavigationActivity()
        ..pageIdentifier = navigation.pageName
        ..data.addAll(navigation.customData
                ?.map((key, value) => MapEntry(key, value.toString())) ??
            {}));
  }

  rpcAPI.Activity notificationClick(NotificationEntity notification,
      {String? uuid, String? time}) {
    final generatedUuid = uuid ?? Uuid().v4();
    final generatedTime = _parseToTimestamp(time);

    return rpcAPI.Activity()
      ..timestamp = generatedTime
      ..id = generatedUuid
      ..type = rpcAPI.ActivityType.ACTIVITY_TRACK
      ..trackPushClick = (rpcAPI.Activity_TrackPushClickActivity()
        ..notification = (rpcAPI.NotificationInfo()
          ..notificationId = notification.notification
          ..dispatchId = notification.notificationLogId ?? ""
          ..contactId = notification.contactId ?? ""
          ..name = notification.name ?? ""
          ..channel = 'mobile')
        ..utmSource = 'source');
  }

  rpcAPI.Activity notificationReceived(NotificationEntity notification,
      {String? uuid, String? time}) {
    final generatedUuid = uuid ?? Uuid().v4();
    final generatedTime = _parseToTimestamp(time);

    return rpcAPI.Activity()
      ..timestamp = generatedTime
      ..id = generatedUuid
      ..type = rpcAPI.ActivityType.ACTIVITY_TRACK
      ..trackPushReceipt = (rpcAPI.Activity_TrackPushReceiptActivity()
        ..notification = (rpcAPI.NotificationInfo()
          ..notificationId = notification.notification
          ..dispatchId = notification.notificationLogId ?? ""
          ..contactId = notification.contactId ?? ""
          ..name = notification.name ?? ""
          ..channel = 'mobile')
        ..utmSource = 'source');
  }

  rpcAPI.Activity registryToken(String token, {String? uuid, String? time}) {
    final generatedUuid = uuid ?? Uuid().v4();
    final generatedTime = _parseToTimestamp(time);

    return rpcAPI.Activity()
      ..timestamp = generatedTime
      ..id = generatedUuid
      ..type = rpcAPI.ActivityType.ACTIVITY_REGISTER
      ..tokenRegister = (rpcAPI.Activity_TokenRegisterActivity()
        ..token = token
        ..provider = rpcAPI.PushProvider.PROVIDER_FCM);
  }

  rpcAPI.Activity pingToken(String token, {String? uuid, String? time}) {
    final generatedUuid = uuid ?? Uuid().v4();
    final generatedTime = _parseToTimestamp(time);

    return rpcAPI.Activity()
      ..timestamp = generatedTime
      ..id = generatedUuid
      ..type = rpcAPI.ActivityType.ACTIVITY_REGISTER
      ..tokenPing = (rpcAPI.Activity_TokenPingActivity()
        ..token = token
        ..provider = rpcAPI.PushProvider.PROVIDER_FCM);
  }

  rpcAPI.Activity removeToken(String token, {String? uuid, String? time}) {
    final generatedUuid = uuid ?? Uuid().v4();
    final generatedTime = _parseToTimestamp(time);

    return rpcAPI.Activity()
      ..timestamp = generatedTime
      ..id = generatedUuid
      ..type = rpcAPI.ActivityType.ACTIVITY_REGISTER
      ..tokenUnregister = (rpcAPI.Activity_TokenUnregisterActivity()
        ..token = token
        ..provider = rpcAPI.PushProvider.PROVIDER_FCM);
  }
}

class ApiInterface {
  String? _apiKey;
  String? _secretKey;

  static final ApiInterface _instance = ApiInterface._internal();

  factory ApiInterface() {
    return _instance;
  }

  ApiInterface._internal();

  void setKeys(String apiKey, String secretKey) {
    _instance._apiKey = apiKey;
    _instance._secretKey = convertToSHA1(secretKey);
  }

  ApiRequest createRequest(List<rpcAPI.Activity> activities) {
    ApiActivities apiActivities = ApiActivities();

    final device = apiActivities.deviceToken;
    final sdk = apiActivities.sdkInfo;
    final app = apiActivities.appInfo;
    final user = apiActivities.userInfo;

    final request = rpcAPI.Request()
      ..user = user
      ..device = device
      ..sdk = sdk
      ..app = app
      ..activities.addAll(activities);

    return ApiRequest(request, _apiKey, _secretKey);
  }
}

class ApiRequest {
  final rpcAPI.Request _request;
  final String? _apiKey;
  final String? _secretKey;

  ApiRequest(this._request, this._apiKey, this._secretKey);

  void _checkConfiguration() {
    if (_apiKey == null || _secretKey == null) {
      throw Exception(
          'API key and Secret Key must be initialized before using. Please call the initialize() method first.');
    }
  }

  Future<int> call() async {
    _checkConfiguration();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/proto',
        'platform_api_key': _apiKey!,
        'sha1_signature': _secretKey!,
      },
      body: _request.writeToBuffer(),
    );

    if (response.statusCode == 200) {
      final responseProto = rpcAPI.Response.fromBuffer(response.bodyBytes);
      for (var responseData in responseProto.response) {
        if (responseData.hasError()) {
          final error = responseData.error;

          switch (error.code) {
            case rpcAPI.ErrorCode.ERROR_INVALID_REQUEST:
              throw ('Invalid request format.');
            case rpcAPI.ErrorCode.ERROR_UNAUTHORIZED:
              throw ('Unauthorized access.');
            case rpcAPI.ErrorCode.ERROR_NOT_FOUND:
              throw ('Resource not found.');
            case rpcAPI.ErrorCode.ERROR_INTERNAL:
              throw ('Internal server error.');
            case rpcAPI.ErrorCode.ERROR_NOT_IMPLEMENTED:
              throw ('Feature not implemented.');
            default:
              throw ('Unknown error occurred.');
          }
        }
      }

      return response.statusCode;
    }

    throw ('Unknown error occurred.');
  }
}
