import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class BingoSets {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    if (!Directory(directory.path + '\\Sets').existsSync()) {
      Directory(directory.path + '\\Sets').createSync();
    }
    return directory.path + '\\Sets';
  }

  static Future<List<String>> get allSets async {
    final directoryPath = await _localPath;
    final directory = Directory(directoryPath);
    return directory
        .list()
        .map((event) => event.path)
        .map((event) => event.substring(event.lastIndexOf("\\") + 1))
        .map((event) => event.contains("/") ? event.split("/")[1] : event)
        .map((event) => event.split(".")[0])
        .toList();
  }

  static Future<void> createSet(String name, List<String> entries) async {
    final String path = await _localPath;
    String allEntries = '';
    File file = File('$path/$name.txt');
    if (!file.existsSync()) {
      file = await file.create();
      for (String entry in entries) {
        allEntries += '$entry\n';
      }
      file.writeAsStringSync(allEntries);
    }
  }

  static Future<void> deleteSet(String name) async {
    final String path = await _localPath;
    await File('$path/$name.txt').delete();
  }

  static Future<void> replaceSet(String name, List<String> entries) async {
    await deleteSet(name);
    await createSet(name, entries);
  }

  static Future<List<String>?> getSet(String name) async {
    final String path = await _localPath;
    File file = File('$path/$name.txt');
    if (!file.existsSync()) return null;
    return file.readAsLinesSync();
  }
}
