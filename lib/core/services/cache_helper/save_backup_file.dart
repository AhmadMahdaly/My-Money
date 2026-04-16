import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:path_provider/path_provider.dart';

Future<File> saveBackupFile() async {
  final jsonString = await CacheHelper.exportToJson();

  final dir = await getApplicationDocumentsDirectory();

  final file = File('${dir.path}/backup.json');

  return file.writeAsString(jsonString);
}

Future<void> pickAndRestoreBackup() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result != null) {
    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();

    await CacheHelper.restoreFromJson(jsonString);
  }
}
