// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  static Future<void> shareBackup() async {
    final data = await CacheHelper.getAllData();
    final jsonString = jsonEncode(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/backup.json');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  }

  static Future<void> restoreFromJson() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) throw Exception('No file selected');
    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final decoded = jsonDecode(jsonString);
    final data = decoded is Map && decoded.containsKey('data')
        ? Map<String, dynamic>.from(decoded['data'] as Map<String, dynamic>)
        : Map<String, dynamic>.from(decoded as Map<String, dynamic>);
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      try {
        if (value is String) {
          await CacheHelper.saveData(key: key, value: value);
        } else if (value is int) {
          await CacheHelper.saveData(key: key, value: value);
        } else if (value is bool) {
          await CacheHelper.saveData(key: key, value: value);
        } else if (value is double) {
          await CacheHelper.saveData(key: key, value: value);
        } else if (value is List) {
          await CacheHelper.saveData(key: key, value: List<String>.from(value));
        }
      } catch (_) {}
    }
  }
}
