import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:x_video_ai/utils/generate_md5_name.dart';

import 'generate_md5_name_test.mocks.dart';

@GenerateMocks([XFile])
void main() {
  late MockXFile mockFile;

  setUp(() {
    mockFile = MockXFile();
  });

  test('should generate correct MD5 hash for given file bytes', () async {
    // Simuler les octets du fichier
    final Uint8List fileBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

    // Simuler la méthode readAsBytes pour renvoyer les octets simulés
    when(mockFile.readAsBytes()).thenAnswer((_) async => fileBytes);

    // Appeler la fonction generateMD5Name
    final String md5Hash = await generateMD5Name(mockFile);

    // Calculer le hash attendu
    final Digest expectedHash = md5.convert(fileBytes);

    // Vérifier que le hash généré est correct
    expect(md5Hash, equals(expectedHash.toString()));
  });

  test('should generate different MD5 hashes for different file contents',
      () async {
    // Simuler des octets pour le premier fichier
    final Uint8List fileBytes1 = Uint8List.fromList([1, 2, 3, 4, 5]);

    // Simuler des octets pour le second fichier
    final Uint8List fileBytes2 = Uint8List.fromList([6, 7, 8, 9, 10]);

    // Simuler la méthode readAsBytes pour le premier fichier
    when(mockFile.readAsBytes()).thenAnswer((_) async => fileBytes1);
    final String md5Hash1 = await generateMD5Name(mockFile);

    // Simuler la méthode readAsBytes pour le second fichier
    when(mockFile.readAsBytes()).thenAnswer((_) async => fileBytes2);
    final String md5Hash2 = await generateMD5Name(mockFile);

    // Vérifier que les deux hashes sont différents
    expect(md5Hash1, isNot(equals(md5Hash2)));
  });

  test('should generate consistent MD5 hash for the same file bytes', () async {
    // Simuler les octets du fichier
    final Uint8List fileBytes = Uint8List.fromList([10, 20, 30, 40, 50]);

    // Simuler la méthode readAsBytes pour renvoyer les octets simulés
    when(mockFile.readAsBytes()).thenAnswer((_) async => fileBytes);

    // Appeler deux fois la fonction generateMD5Name
    final String md5Hash1 = await generateMD5Name(mockFile);
    final String md5Hash2 = await generateMD5Name(mockFile);

    // Vérifier que les deux hashes sont identiques
    expect(md5Hash1, equals(md5Hash2));
  });
}
