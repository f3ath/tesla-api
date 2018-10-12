import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

expectRequest(HttpRequest r, {path, jsonBody, method, headers}) async {
  if (path != null) {
    expect(r.uri.toString(), path);
  }
  if (jsonBody != null) {
    expect(await r.transform(utf8.decoder).reduce((a, b) => a + b),
        json.encode(jsonBody));
  }
  if (method != null) {
    expect(r.method, method);
  }

  if (headers != null) {
    expect(r.headers, headers);
  }
}
