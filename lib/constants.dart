import 'dart:io';

class Constants {
  static String platform = Platform.isIOS ? 'iPhone' : 'Android';
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
            "https://notification.plataformasocial.com.br/users/{}/mobile-tokens/"
                .replaceFirst("{}", id);
        break;
      case "Endpoint.removeMobileTokens":
        value =
            "https://notification.plataformasocial.com.br/users/{}/mobile-tokens/disable/"
                .replaceFirst("{}", id);
        break;
      case "Endpoint.events":
        value =
            "http://events.plataformasocial.com.br/users/{}"
            .replaceFirst("{}", id);
        break;
      case "Endpoint.openNotification":
        value =
            "https://notification.plataformasocial.com.br/notifications/{}/open"
                .replaceFirst("{}", id);
        break;
      default:
        value = "https://login.plataformasocial.com.br/users/portal/{}/signup"
            .replaceFirst("{}", id);
        break;
    }

    return value;
  }
}
