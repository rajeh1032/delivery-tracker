import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@lazySingleton
class ProofStorageService {
  Future<String> saveProofFile(File sourceFile, String actionId) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final proofsDir = Directory('${docsDir.path}/proofs');
    if (!await proofsDir.exists()) {
      await proofsDir.create(recursive: true);
    }

    final targetPath = '${proofsDir.path}/$actionId.jpg';
    final savedFile = await sourceFile.copy(targetPath);
    return savedFile.path;
  }

  File? getProofFile(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  Future<void> deleteProofFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
