import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:delivery_tracker/core/services/proof_storage_service.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  final String appDocsPath;

  FakePathProviderPlatform(this.appDocsPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => appDocsPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late ProofStorageService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('proof_storage_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
    service = ProofStorageService();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('saveProofFile copies source photo to proofs directory and returns target path',
      () async {
    final sourceFile = File('${tempDir.path}/source_test.jpg');
    await sourceFile.writeAsString('test photo content');

    final targetPath = await service.saveProofFile(sourceFile, 'action-123');

    expect(targetPath, '${tempDir.path}/proofs/action-123.jpg');
    final savedFile = File(targetPath);
    expect(await savedFile.exists(), isTrue);
    expect(await savedFile.readAsString(), 'test photo content');
  });

  test('getProofFile returns File when existing, null otherwise', () async {
    final existingFile = File('${tempDir.path}/test_exist.jpg');
    await existingFile.writeAsString('exist');

    final found = service.getProofFile(existingFile.path);
    final notFound = service.getProofFile('${tempDir.path}/non_existent.jpg');

    expect(found, isNotNull);
    expect(notFound, isNull);
  });

  test('deleteProofFile removes file safely if exists', () async {
    final file = File('${tempDir.path}/to_delete.jpg');
    await file.writeAsString('delete me');

    expect(await file.exists(), isTrue);
    await service.deleteProofFile(file.path);
    expect(await file.exists(), isFalse);
  });
}
