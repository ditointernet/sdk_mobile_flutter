import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../event/event_entity.dart';
import '../event/navigation_entity.dart';
import '../notification/notification_entity.dart';
import '../proto/api.pb.dart' as rpcAPI;
import '../proto/google/protobuf/timestamp.pb.dart';
import '../user/user_interface.dart';
import '../utils/sha1.dart';

const url = 'http://10.0.2.2:3000/connect.sdk_api.v1.SDKService/Activity';

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

  rpcAPI.DeviceInfo get deviceToken => rpcAPI.DeviceInfo()
    ..os = rpcAPI.DeviceOs.DEVICE_OS_ANDROID
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

    if (_userInterface.data.id != null &&
        _userInterface.data.id!.isNotEmpty) {
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

    if (_userInterface.data.gender != null &&
        _userInterface.data.gender!.isNotEmpty) {
      user.gender = _userInterface.data.gender!;
    }

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

    return user;
  }

  rpcAPI.Activity identify() {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    return rpcAPI.Activity()
      ..timestamp = now
      ..id = uuid.v4()
      ..type = rpcAPI.ActivityType.ACTIVITY_IDENTIFY
      ..userData = rpcAPI.Activity_UserDataActivity();
  }

  rpcAPI.Activity login() {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    return rpcAPI.Activity()
      ..timestamp = now
      ..id = uuid.v4()
      ..type = rpcAPI.ActivityType.ACTIVITY_TRACK
      ..userLogin = (rpcAPI.Activity_UserLoginActivity()..utmSource = 'source');
  }

  rpcAPI.Activity trackEvent(EventEntity event) {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    return rpcAPI.Activity()
      ..timestamp = now
      ..id = uuid.v4()
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

  rpcAPI.Activity trackNavigation(NavigationEntity navigation) {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    return rpcAPI.Activity()
      ..timestamp = now
      ..id = uuid.v4()
      ..type = rpcAPI.ActivityType.ACTIVITY_TRACK
      ..trackNavigation = (rpcAPI.Activity_TrackNavigationActivity()
        ..pageIdentifier = navigation.pageName
        ..data.addAll(navigation.customData
                ?.map((key, value) => MapEntry(key, value.toString())) ??
            {}));
  }

  rpcAPI.Activity notificationClick(NotificationEntity notification) {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    return rpcAPI.Activity()
      ..timestamp = now
      ..id = uuid.v4()
      ..type = rpcAPI.ActivityType.ACTIVITY_TRACK
      ..trackPushClick = (rpcAPI.Activity_TrackPushClickActivity()
        ..notification = (rpcAPI.NotificationInfo()
          ..notificationId = notification.notification
          ..dispatchId = notification.identifier)
        ..utmSource = 'source');
  }

  rpcAPI.Activity notificationReceived(NotificationEntity notification) {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    return rpcAPI.Activity()
      ..timestamp = now
      ..id = uuid.v4()
      ..type = rpcAPI.ActivityType.ACTIVITY_TRACK
      ..trackPushReceipt = (rpcAPI.Activity_TrackPushReceiptActivity()
        ..notification = (rpcAPI.NotificationInfo()
          ..notificationId = notification.notification
          ..dispatchId = notification.identifier)
        ..utmSource = 'source');
  }

  rpcAPI.Activity registryToken(String token) {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    return rpcAPI.Activity()
      ..timestamp = now
      ..id = uuid.v4()
      ..type = rpcAPI.ActivityType.ACTIVITY_REGISTER
      ..tokenRegister = (rpcAPI.Activity_TokenRegisterActivity()
        ..token = token
        ..provider = rpcAPI.PushProvider.PROVIDER_FCM);
  }

  rpcAPI.Activity pingToken(String token) {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    return rpcAPI.Activity()
      ..timestamp = now
      ..id = uuid.v4()
      ..type = rpcAPI.ActivityType.ACTIVITY_REGISTER
      ..tokenPing = (rpcAPI.Activity_TokenPingActivity()
        ..token = token
        ..provider = rpcAPI.PushProvider.PROVIDER_FCM);
  }

  rpcAPI.Activity removeToken(String token) {
    const uuid = Uuid();
    final now = Timestamp.fromDateTime(DateTime.now());

    return rpcAPI.Activity()
      ..timestamp = now
      ..id = uuid.v4()
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

  Future<bool> call() async {
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

      return true;
    }

    throw ('Unknown error occurred.');
  }
}
