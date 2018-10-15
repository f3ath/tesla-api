import 'package:args/command_runner.dart';
import 'package:tesla/api.dart';
import 'package:tesla/src/cli/console.dart';

class Auth extends Command {
  final name = 'auth';
  final description = 'Gets oath token.';
  final Console _console;
  final TeslaClient _client;

  Auth(Console this._console, TeslaClient this._client) {
    argParser.addOption('email', abbr: 'e', help: 'Your Tesla account email');
    argParser.addOption('password',
        abbr: 'p', help: 'Your Tesla account password');
    argParser.addOption('client-id',
        abbr: 'i',
        help: 'API client id',
        defaultsTo:
            '81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384');
    argParser.addOption('client-secret',
        abbr: 's',
        help: 'API client secret',
        defaultsTo:
            'c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3');
  }

  @override
  run() async {
    final email = argResults['email'];
    final password = argResults['password'];
    final id = argResults['client-id'];
    final secret = argResults['client-secret'];
    final auth = await _client.auth(email, password, id, secret);
    [
      'token: ${auth.accessToken}',
      'expires in: ${auth.expiresIn}',
      'refresh token: ${auth.refreshToken}',
      'created at: ${auth.createdAt.toLocal()}'
    ].forEach(_console.log);
  }
}
