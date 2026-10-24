import 'dart:io';
import 'package:path_provider/path_provider.dart';

void saveAndLaunchFile(List<int> bytes, String fileName, String mimeType) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
  } catch (_) {}
}
