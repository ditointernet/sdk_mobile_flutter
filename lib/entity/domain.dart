class Domain {
  final String url;

  Domain(this.url);

  String get uri {
    return url;
  }

  List<String> get spited {
    int idx = url.indexOf("/");
    return [url.substring(0, idx).trim(), url.substring(idx + 1).trim()];
  }
}
