import 'dart:io';

import 'package:tesla/api.dart';
import 'package:tesla/cli.dart';

void main(List<String> args) async {
  final http = HttpClient();
  await App(Console(), TeslaClient(http)).run(args);
  http.close();
}
