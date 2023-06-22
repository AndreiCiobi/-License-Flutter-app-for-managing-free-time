import 'dart:convert';

String decode(String encoded) => utf8.decode(base64.decode(encoded));
