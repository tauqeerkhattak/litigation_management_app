import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileService {
  Future<String> saveFile(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(file.path);
    final savedFile = await file.copy('${appDir.path}/$fileName');
    return savedFile.path;
  }

  Future<File?> getFile(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$fileName');
    if (await file.exists()) {
      return file;
    }
    return null;
  }
}
