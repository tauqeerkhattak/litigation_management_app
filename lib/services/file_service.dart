part of 'locator.dart';

class FileService {
  FileService._();

  final _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(
    String userId,
    String caseId,
    PlatformFile file,
  ) async {
    final ref = _storage.ref('$userId/files/$caseId/${file.name}');
    final bytes = await file.xFile.readAsBytes();
    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String userId, String caseId, String fileName) async {
    log('NAME: $fileName');
    final ref = _storage.ref('$userId/files/$caseId/$fileName');
    await ref.delete();
  }
}
