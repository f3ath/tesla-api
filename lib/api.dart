import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tesla/src/api/method.dart';

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

class TeslaClientException implements IOException {
  final HttpHeaders headers;
  final int status;
  final String body;

  TeslaClientException(
      int this.status, HttpHeaders this.headers, String this.body);
}

class InvalidTokenException implements IOException {}

class TeslaClient {
  final HttpClient http;
  final String host;
  final String userAgent;
  String token;

  TeslaClient(HttpClient this.http,
      {String this.host = 'https://owner-api.teslamotors.com',
      String this.userAgent = 'Dart Tesla API client',
      String this.token});

  Future<AuthResponse> auth(String email, String password, String clientId,
          String clientSecret) async =>
      AuthResponse.fromJson(
          await call(Method.post, '/oauth/token', needsAuth: false, body: {
        'grant_type': 'password',
        'client_id': clientId,
        'client_secret': clientSecret,
        'email': email,
        'password': password
      }));

  Future<List<Vehicle>> listVehicles() async => List.from(
      ((await call(Method.get, '/api/1/vehicles'))['response'] as List)
          .map((j) => Vehicle.fromJson(j)));

  Future<Map<String, dynamic>> call(Method method, String path,
      {Map<String, dynamic> body, bool needsAuth = true}) async {
    final request = await method.open(http, Uri.parse(host + path));
    request.headers.set(HttpHeaders.userAgentHeader, userAgent);
    request.headers.contentType =
        ContentType("application", "json", charset: "utf-8");
    if (needsAuth) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) request.write(json.encode(body));
    final response = await request.close();
    final responseBody =
        await response.transform(utf8.decoder).reduce((a, b) => a + b);
    if (response.statusCode != HttpStatus.ok) {
      final authHeaders = response.headers[HttpHeaders.wwwAuthenticateHeader];
      if (authHeaders != null &&
          authHeaders.isNotEmpty &&
          authHeaders.any((header) => header.contains('error="invalid_token')))
        throw InvalidTokenException();
      throw TeslaClientException(
          response.statusCode, response.headers, responseBody);
    }
    if (responseBody.isEmpty) return null;
    return json.decode(responseBody);
  }
}
