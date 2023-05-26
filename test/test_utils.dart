import 'dart:io';
import 'dart:math';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );

List<File> getFiles(Directory directory) {
  List<FileSystemEntity> fileList = directory.listSync();
  fileList.sort((a, b) {
    return a.path.compareTo(b.path);
  });

  return fileList.whereType<File>().toList();
}
