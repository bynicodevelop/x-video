import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/utils/generate_md5_name.dart';

class FakeXFile extends XFile {
  final Uint8List _bytes;

  FakeXFile(this._bytes) : super.fromData(_bytes);

  @override
  Future<Uint8List> readAsBytes() async {
    return _bytes;
  }
}

void main() {
  test('should generate correct MD5 hash for given file bytes', () async {
    // Simuler les octets du fichier
    final Uint8List fileBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

    // Créer une instance de FakeXFile
    final fakeFile = FakeXFile(fileBytes);

    // Appeler la fonction generateMD5Name
    final String md5Hash = await generateMD5Name(fakeFile);

    // Calculer le hash attendu
    final Digest expectedHash = md5.convert(fileBytes);

    // Vérifier que le hash généré est correct
    expect(md5Hash, equals(expectedHash.toString()));
  });

  test('should generate different MD5 hashes for different file contents',
      () async {
    // Simuler des octets pour le premier fichier
    final Uint8List fileBytes1 = Uint8List.fromList([1, 2, 3, 4, 5]);
    final fakeFile1 = FakeXFile(fileBytes1);

    // Simuler des octets pour le second fichier
    final Uint8List fileBytes2 = Uint8List.fromList([6, 7, 8, 9, 10]);
    final fakeFile2 = FakeXFile(fileBytes2);

    // Appeler la fonction generateMD5Name pour les deux fichiers
    final String md5Hash1 = await generateMD5Name(fakeFile1);
    final String md5Hash2 = await generateMD5Name(fakeFile2);

    // Vérifier que les deux hashes sont différents
    expect(md5Hash1, isNot(equals(md5Hash2)));
  });

  test('should generate consistent MD5 hash for the same file bytes', () async {
    // Simuler les octets du fichier
    final Uint8List fileBytes = Uint8List.fromList([10, 20, 30, 40, 50]);
    final fakeFile = FakeXFile(fileBytes);

    // Appeler deux fois la fonction generateMD5Name
    final String md5Hash1 = await generateMD5Name(fakeFile);
    final String md5Hash2 = await generateMD5Name(fakeFile);

    // Vérifier que les deux hashes sont identiques
    expect(md5Hash1, equals(md5Hash2));
  });
}
