import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> getTempDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  static Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  static Future<File> writeFile(String path, List<int> bytes) async {
    final file = File(path);
    return file.writeAsBytes(bytes);
  }

  static Future<List<int>> readFile(String path) async {
    final file = File(path);
    return file.readAsBytes();
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await fileExists(path)) {
      await file.delete();
    }
  }
}
