import 'dart:convert';
import 'dart:io';

import 'package:tesla/api.dart';
import 'package:tesla/src/test_helper.dart';
import 'package:test/test.dart';

void main() {
  group('API Client', () {
    HttpServer server;
    TeslaClient client;

    setUp(() async {
      server = await HttpServer.bind('localhost', 8080);
      client = TeslaClient(HttpClient(), host: 'http://localhost:8080');
    });

    tearDown(() async {
      await server.close();
    });

    test('auth', () async {
      server.listen((r) {
        expectRequest(
          r,
          method: 'POST',
          path: '/oauth/token',
          jsonBody: {
            'grant_type': 'password',
            'client_id': 'id',
            'client_secret': 'secret',
            'email': 'tesla@example.com',
            'password': 'pass'
          },
          headers: (HttpHeaders h) =>
              h.value('User-Agent') == 'Dart Tesla API client',
        );
        r.response.write(json.encode({
          "access_token": "abc123",
          "token_type": "bearer",
          "expires_in": 3888000,
          "refresh_token": "cba321",
          "created_at": 1538359034
        }));
        r.response.close();
      });

      final auth =
          await client.auth('tesla@example.com', 'pass', 'id', 'secret');
      expect(auth.accessToken, 'abc123');
      expect(auth.expiresIn, 3888000);
    });

    test('vehicle list', () async {
      server.listen((r) {
        expectRequest(
          r,
          method: 'GET',
          path: '/api/1/vehicles',
          headers: (HttpHeaders h) =>
              h.value('Authorization') == 'Bearer abc123' &&
              h.value('User-Agent') == 'Dart Tesla API client',
        );
        r.response.write(json.encode({
          "response": [
            {
              "id": 12345678901234567,
              "vehicle_id": 1234567890,
              "vin": "5YJSA11111111111",
              "display_name": "Nikola 2.0",
              "option_codes":
                  "MDLS,RENA,AF02,APF1,APH2,APPB,AU01,BC0R,BP00,BR00,BS00,CDM0,CH05,PBCW,CW00,DCF0,DRLH,DSH7,DV4W,FG02,FR04,HP00,IDBA,IX01,LP01,ME02,MI01,PF01,PI01,PK00,PS01,PX00,PX4D,QTVB,RFP2,SC01,SP00,SR01,SU01,TM00,TP03,TR00,UTAB,WTAS,X001,X003,X007,X011,X013,X021,X024,X027,X028,X031,X037,X040,X044,YFFC,COUS",
              "color": null,
              "tokens": ["abcdef1234567890", "1234567890abcdef"],
              "state": "online",
              "in_service": false,
              "id_s": "12345678901234567",
              "calendar_enabled": true,
              "backseat_token": null,
              "backseat_token_updated_at": null
            }
          ],
          "count": 1
        }));
        r.response.close();
      });

      client.token = 'abc123';
      final vehicles = await client.listVehicles();
      expect(vehicles.length, 1);
      expect(vehicles[0].id, 12345678901234567);
      expect(vehicles[0].vehicleId, 1234567890);
      expect(vehicles[0].vin, "5YJSA11111111111");
      expect(vehicles[0].displayName, "Nikola 2.0");
    });
  });
}
