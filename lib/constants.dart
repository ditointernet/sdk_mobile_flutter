import 'dart:io';

class Constants {
  static String platform = Platform.isIOS ? 'iPhone' : 'Android';
  static Endpoints endpoints = Endpoints();
}

enum Endpoint {
  identify,
  registryMobileTokens,
  removeMobileTokens,
  events,
  openNotification;

  replace(String from, String to) {
    String? value;

    switch (toString()) {
      case "Endpoint.registryMobileTokens":
        value =
            "https://notification.plataformasocial.com.br/users/{}/mobile-tokens/"
                .replaceFirst(from, to);
        break;
      case "Endpoint.removeMobileTokens":
        value =
            "https://notification.plataformasocial.com.br/users/{}/mobile-tokens/disable/"
            .replaceFirst(from, to);
        break;
      case "Endpoint.events":
        value =
            "http://events.plataformasocial.com.br/users/{}"
                .replaceFirst(from, to);
        break;
      case "Endpoint.openNotification":
        value =
            "https://notification.plataformasocial.com.br/notifications/{}/open"
                .replaceFirst(from, to);
        break;
      default:
        value = "https://login.plataformasocial.com.br/users/portal/{}/signup"
            .replaceFirst(from, to);
        break;
    }

    return value;
  }
}

class Endpoints {
  replace({required String value, required Endpoint endpoint}) {
    return endpoint.replace("{}", value);
  }
}
