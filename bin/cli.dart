import 'dart:io';

import 'package:tesla/api.dart';
import 'package:tesla/cli.dart';

void main(List<String> args) async =>
    await App(Console(), TeslaClient(HttpClient())).run(args);
