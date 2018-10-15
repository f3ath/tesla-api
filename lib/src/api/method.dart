import 'dart:async';
import 'dart:io';

abstract class Method {
  static const Method post = _Post();
  static const Method get = _Get();

  Future<HttpClientRequest> open(HttpClient http, Uri uri);
}

class _Post implements Method {
  const _Post();

  @override
  Future<HttpClientRequest> open(HttpClient http, Uri url) async =>
      http.postUrl(url);
}

class _Get implements Method {
  const _Get();

  @override
  Future<HttpClientRequest> open(HttpClient http, Uri url) async =>
      http.getUrl(url);
}
