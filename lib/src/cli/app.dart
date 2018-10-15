import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:tesla/api.dart';
import 'package:tesla/src/cli/commands/auth.dart';
import 'package:tesla/src/cli/commands/list_vehicles.dart';
import 'package:tesla/src/cli/console.dart';

class App extends CommandRunner {
  final Console console;

  App(Console this.console, TeslaClient client)
      : super('Tesla CLI', 'Command line client for Tesla API') {
    [Auth(console, client), ListVehicles(console, client)].forEach(addCommand);
  }

  @override
  Future<dynamic> run(Iterable<String> args) async {
    try {
      return await super.run(args);
    } on UsageException catch (e) {
      console.logError(e);
    } on InvalidTokenException {
      console.logError('Invalid token. Try to reauthenticate.');
    } on TeslaClientException catch (e) {
      ['Http Exception. Status: ${e.status}', e.headers.toString()]
          .forEach(console.logError);
    }
    return null;
  }
}
