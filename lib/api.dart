import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum Method { get, post }

abstract class Request {
  String get path;

  Method get method;

  Map<String, dynamic> get body;
}

class AuthRequest implements Request {
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

class AuthResponse {
  final String accessToken;

  final int expiresIn;

  final String refreshToken;

  final DateTime createdAt;

  AuthResponse(String this.accessToken, int this.expiresIn,
      String this.refreshToken, DateTime this.createdAt);

  AuthResponse.fromJson(Map<String, dynamic> j)
      : accessToken = j['access_token'],
        expiresIn = j['expires_in'],
        refreshToken = j['refresh_token'],
        createdAt = DateTime.fromMillisecondsSinceEpoch(j['created_at'] * 1000,
            isUtc: true);
}

class ListVehiclesRequest {
  final String path = '/api/1/vehicles';
}

class Vehicle {
  final int id;
  final int vehicleId;
  final String vin;
  final String displayName;

  Vehicle(int this.id, int this.vehicleId, String this.vin,
      String this.displayName);

  Vehicle.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        vehicleId = j['vehicle_id'],
        vin = j['vin'],
        displayName = j['display_name'];
}

class HttpClientException implements IOException {}

class TeslaClient {
  final HttpClient _http;
  final String _host;
  final String _userAgent;

  TeslaClient(HttpClient this._http,
      {String host = 'https://owner-api.teslamotors.com',
      String userAgent = 'Dart Tesla API client'})
      : _host = host,
        _userAgent = userAgent;

  /// Gets oauth token.
  ///
  /// [email] and [password] are the same you'd use on tesla.com.
  /// [id] and [secret] identify the client.
  Future<AuthResponse> auth(
          String email, String password, String id, String secret) async =>
      AuthResponse.fromJson(
          await _perform(AuthRequest(email, password, id, secret)));

  /// Gets the list of the vehicles tied to the account.
  Future<List<Vehicle>> listVehicles() async {
    final req = ListVehiclesRequest();
    final res = await _http.getUrl(Uri.parse(_host + req.path)).then((r) {
      r.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      r.headers.set(HttpHeaders.authorizationHeader, 'Bearer abc123');
      r.headers.contentType =
          ContentType("application", "json", charset: "utf-8");
      return r.close();
    });
    final body =
        await res.transform(utf8.decoder).reduce((acc, el) => acc + el);
    return List.from(
        json.decode(body)['response'].map((v) => Vehicle.fromJson(v)));
  }

  Future<Map<String, dynamic>> _perform(Request apiRequest) async {
    final url = Uri.parse(_host + apiRequest.path);
    final httpRequest = await (_http.postUrl(url));

    final res = await _http.postUrl(url).then((r) {
      r.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      r.headers.contentType =
          ContentType("application", "json", charset: "utf-8");
      r.write(json.encode(apiRequest.body));
      return r.close();
    });
    return json.decode(
        await res.transform(utf8.decoder).reduce((acc, el) => acc + el));
  }
}
