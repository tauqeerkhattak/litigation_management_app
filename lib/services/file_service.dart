part of 'locator.dart';

class FileService {
  FileService._();
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

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> renameFile(String oldPath, String newName) async {
    final file = File(oldPath);
    if (await file.exists()) {
      final dir = p.dirname(oldPath);
      final extension = p.extension(oldPath);
      final newPath = p.join(dir, '$newName$extension');
      final renamedFile = await file.rename(newPath);
      return renamedFile.path;
    }
    throw Exception("File not found");
  }
}
