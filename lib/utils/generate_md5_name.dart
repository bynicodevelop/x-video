import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';

Future<String> generateMD5Name(XFile file) async {
  final Uint8List fileBytes = await file.readAsBytes();
  final Digest md5Hash = md5.convert(fileBytes);
  return md5Hash.toString();
}

Future<String> generateMD5NameFromString(String string) async {
  final Digest md5Hash = md5.convert(string.codeUnits);
  return md5Hash.toString();
}
