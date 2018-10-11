import 'dart:async';
import 'dart:convert';
import 'dart:io';

class AuthResponse {
  final String accessToken;

  AuthResponse(String this.accessToken);

  AuthResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'];
}

enum Method { get, post }

abstract class TeslaRequest {
  String get path;

  Method get method;

  Map<String, dynamic> get body;
}

class AuthRequest implements TeslaRequest {
  final method = Method.post;
  final path = '/oauth/token';
  final Map<String, dynamic> body;

  AuthRequest(String email, String password, String id, String secret)
      : body = {
          'grant_type': 'password',
          'client_id': id,
          'client_secret': secret,
          'email': email,
          'password': password
        };
}

class HttpClientException implements IOException {}

class TeslaClient {
  final HttpClient _http;

  TeslaClient(HttpClient this._http);

  Future<AuthResponse> auth(
      String email, String password, String id, String secret) async {
    final req = AuthRequest(email, password, id, secret);
    final res = await _http
        .postUrl(Uri.parse('https://owner-api.teslamotors.com' + req.path))
        .then((r) {
      r.headers.set(HttpHeaders.userAgentHeader, 'Dart Tesla API client');
      r.headers.contentType =
          ContentType("application", "json", charset: "utf-8");
      r.write(json.encode(req.body));
      return r.close();
    });
    final body =
        await res.transform(utf8.decoder).reduce((acc, el) => acc + el);
    return AuthResponse.fromJson(json.decode(body));
  }
}
