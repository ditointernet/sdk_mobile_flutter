import 'dart:convert';
import 'package:crypto/crypto.dart';

String convertToSHA1(String input) {
  final bytes = utf8.encode(input);
  final digest = sha1.convert(bytes);

  return digest.toString();
}
