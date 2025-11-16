import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }

  static Future<File> writeFile(String filePath, List<int> bytes) async {
    final file = File(filePath);
    return file.writeAsBytes(bytes);
  }

  static Future<List<int>> readFile(String filePath) async {
    final file = File(filePath);
    return file.readAsBytes();
  }

  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await fileExists(filePath)) {
      await file.delete();
    }
  }
}