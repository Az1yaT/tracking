import 'dart:io';

Future<String?> pickFile() async {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    throw UnsupportedError('File picking is not supported on this platform.');
  }
  return null;
}