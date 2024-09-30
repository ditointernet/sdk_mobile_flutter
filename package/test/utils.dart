import 'dart:convert';
import 'dart:io';

dynamic testEnv() async {
  final file = File('test/.env-test.json');
  final json = jsonDecode(await file.readAsString());
  return json;
}

