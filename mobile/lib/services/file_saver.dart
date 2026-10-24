import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart';

void downloadFile(List<int> bytes, String fileName, {String mimeType = 'application/octet-stream'}) {
  saveAndLaunchFile(bytes, fileName, mimeType);
}
