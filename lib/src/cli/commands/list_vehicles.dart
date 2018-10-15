import 'package:args/command_runner.dart';
import 'package:tesla/api.dart';
import 'package:tesla/src/cli/console.dart';

class ListVehicles extends Command {
  final name = 'vehicles';
  final description = 'Shows the list of vehicles registered in your account';
  final Console _console;
  final TeslaClient _client;

  ListVehicles(Console this._console, TeslaClient this._client) {
    argParser.addOption('token', abbr: 't', help: 'Access token');
  }

  @override
  run() async {
    _client.token = argResults['token'];
    int counter = 1;
    final vehicles = await _client.listVehicles();
    vehicles.forEach((v) => _console.log(
        '${counter++}. "${v.displayName}" VIN: ${v.vin}, id: ${v.id}, vehicle id: ${v.vehicleId}'));
  }
}
