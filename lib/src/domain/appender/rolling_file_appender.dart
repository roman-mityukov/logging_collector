import 'dart:io';

import 'package:logging_collector/src/domain/appender/logger_appender.dart';

class RollingFileAppender implements LoggerAppender {
  final String dirPath;
  final int fileMaxCount;
  final int fileMaxSize;

  RollingFileAppender({
    required this.dirPath,
    required this.fileMaxCount,
    required this.fileMaxSize,
  })  : assert(fileMaxCount > 0),
        assert(fileMaxSize > 0);

  @override
  Future<void> append(String log) async {
    final directory = Directory(dirPath);

    if (!(await directory.exists())) {
      throw StateError('Error! Directory $dirPath does not exist');
    }

    final logBytes = log.codeUnits;
    final logBytesLength = logBytes.length;

    if (logBytesLength > fileMaxSize) {
      throw ArgumentError('Error! Log is too long');
    }

    final file = await _getFile(directory, logBytesLength);

    await file.writeAsBytes(logBytes, mode: FileMode.append);
  }

  Future<File> _getFile(Directory directory, int logBytesLength) async {
    List<File> fileList = await _getFileList(directory);

    File file;

    if (fileList.isEmpty) {
      file = await _createFile(0);
    } else {
      file = fileList.last;

      if ((await file.length()) + logBytesLength > fileMaxSize) {
        if (fileList.length < fileMaxCount) {
          final nextFileIndex = fileList.length;
          await _createFile(nextFileIndex);
        }

        file = await _rollFiles(directory);
      }
    }

    return file;
  }

  Future<File> _createFile(int index) async {
    final result = File('$dirPath/file$index.log');
    await result.create(recursive: true);
    return result;
  }

  Future<List<File>> _getFileList(Directory directory) async {
    final List<File> fileList = <File>[];
    await for (final entity in directory.list()) {
      if (entity is File) {
        fileList.add(entity);
      }
    }

    fileList.sort((a, b) {
      return a.path.compareTo(b.path);
    });

    return fileList;
  }

  Future<File> _rollFiles(Directory directory) async {
    final files = await _getFileList(directory);

    for (int i = files.length - 1; i >= 1; i--) {
      final newestFile = files[i];
      final oldestFile = files[i - 1];

      await newestFile.writeAsBytes(await oldestFile.readAsBytes());
    }

    final result = files.first;
    await result.writeAsBytes([]);
    return result;
  }
}
