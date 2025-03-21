import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Constants {
  String platform = Platform.isIOS ? 'Apple iPhone' : 'Android';

  Future<String> getUserAgent() async {
    final deviceInfo = DeviceInfoPlugin();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version;
    final String appName = packageInfo.appName;
    String system;
    String model;

    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      system = 'iOS ${ios.systemVersion}';
      model = ios.model;
    } else {
      final android = await deviceInfo.androidInfo;
      system = 'Android ${android.version}';
      model = android.model;
    }
    return '$appName/$version ($system; $model)';
  }
}

enum Endpoint {
  identify,
  registryMobileTokens,
  removeMobileTokens,
  events,
  openNotification;

  replace(String id) {
    String? value;

    switch (toString()) {
      case "Endpoint.registryMobileTokens":
        value =
            "notification.plataformasocial.com.br/users/{}/mobile-tokens/"
                .replaceFirst("{}", id);
        break;
      case "Endpoint.removeMobileTokens":
        value =
            "notification.plataformasocial.com.br/users/{}/mobile-tokens/disable/"
                .replaceFirst("{}", id);
        break;
      case "Endpoint.events":
        value =
            "events.plataformasocial.com.br/users/{}"
            .replaceFirst("{}", id);
        break;
      case "Endpoint.openNotification":
        value =
            "notification.plataformasocial.com.br/notifications/{}/open"
                .replaceFirst("{}", id);
        break;
      default:
        value = "login.plataformasocial.com.br/users/portal/{}/signup"
            .replaceFirst("{}", id);
        break;
    }

    return value;
  }
}
