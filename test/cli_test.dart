import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:mockito/mockito.dart';
import 'package:tesla/api.dart';
import 'package:tesla/cli.dart';
import 'package:test/test.dart';

class ConsoleMock extends Mock implements Console {}

class ClientMock extends Mock implements TeslaClient {}

void main() {
  group('Console app', () {
    ConsoleMock console;
    ClientMock client;
    CommandRunner app;

    setUp(() {
      console = ConsoleMock();
      client = ClientMock();
      app = App(console, client);
      when(client.auth(
              'user@example.com', 'ilovetesla', 'client_id', 'client_secret'))
          .thenAnswer((_) => Future.value(AuthResponse('abc123', 3888000,
              'cba321', DateTime.parse('2018-09-30 18:57:14'))));

      when(client.listVehicles()).thenAnswer((_) =>
          Future.value([Vehicle(123123, 999888777, 'ABC000321', 'Red Fury')]));
    });

    test('auth', () async {
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

      expect(verify(console.log(captureAny)).captured, [
        'token: abc123',
        'expires in: 3888000',
        'refresh token: cba321',
        'created at: 2018-09-30 18:57:14.000'
      ]);
    });

    test('list-vehicles', () async {
      await app.run([
        'vehicles',
        '-t',
        'abc123',
      ]);

      expect(verify(console.log(captureAny)).captured, [
        '1. "Red Fury" VIN: ABC000321, id: 123123, vehicle id: 999888777',
      ]);
    });
  });
}
