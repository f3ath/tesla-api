import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:mockito/mockito.dart';
import 'package:tesla/api.dart';
import 'package:tesla/cli.dart';
import 'package:test/test.dart';

class ConsoleMock extends Mock implements Console {}

class ClientMock extends Mock implements TeslaClient {}

void main() {
  group('auth', () {
    ConsoleMock console;
    ClientMock client;
    CommandRunner app;

    const authResponse = {
      "access_token": "abc123",
      "token_type": "bearer",
      "expires_in": 3888000,
      "refresh_token": "cba321",
      "created_at": 1538359034
    };

    setUp(() {
      console = ConsoleMock();
      client = ClientMock();
      app = App(console, client);
      when(client.auth(
              'user@example.com', 'ilovetesla', 'client_id', 'client_secret'))
          .thenAnswer((_) => Future.value(AuthResponse.fromJson(authResponse)));
    });

    test('calls the client and displays token', () async {
      await app.run([
        'auth',
        '-e',
        'user@example.com',
        '-p',
        'ilovetesla',
        '-i',
        'client_id',
        '-s',
        'client_secret'
      ]);

      expect(verify(console.log(captureAny)).captured.single, 'abc123');
    });
  });
}

