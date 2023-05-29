import 'dart:collection';
import 'dart:io';

import 'package:logging_collector/src/domain/appender/logger_appender.dart';

class Task {
  final String log;
  final Future Function(String) action;

  Task(this.log, this.action);
}

class RollingFileAppender implements LoggerAppender {
  final String _dirPath;
  final int _fileMaxCount;
  final int _fileMaxSize;
  final Queue<Task> _queue = Queue();

  RollingFileAppender({
    required String dirPath,
    required int fileMaxCount,
    required int fileMaxSize,
  })  : _fileMaxSize = fileMaxSize,
        _fileMaxCount = fileMaxCount,
        _dirPath = dirPath,
        assert(fileMaxCount > 0),
        assert(fileMaxSize > 0);

  @override
  Future<void> append(String log) async {
    _queue.add(
      Task(
        log,
        (log) async {
          final directory = Directory(_dirPath);

          if (!(await directory.exists())) {
            throw StateError('Error! Directory $_dirPath does not exist');
          }

          final logBytes = log.codeUnits;
          final logBytesLength = logBytes.length;

          if (logBytesLength > _fileMaxSize) {
            throw ArgumentError('Error! Log is too long');
          }

          final file = await _getFile(directory, logBytesLength);

          await file.writeAsBytes(logBytes, mode: FileMode.append);
        },
      ),
    );
    _startExecution();
  }

  bool _isStarted = false;

  Future<void> _startExecution() async {
    if (_isStarted) return;

    while (_queue.isNotEmpty) {
      _isStarted = true;
      final task = _queue.removeLast();
      await task.action.call(task.log);
      _isStarted = false;
    }
  }

  Future<File> _getFile(Directory directory, int logBytesLength) async {
    List<File> fileList = await _getFileList(directory);

    File file;

    if (fileList.isEmpty) {
      file = await _createFile(0);
    } else {
      file = fileList.last;

      if ((await file.length()) + logBytesLength > _fileMaxSize) {
        if (fileList.length < _fileMaxCount) {
          final nextFileIndex = fileList.length;
          await _createFile(nextFileIndex);
        }

        file = await _rollFiles(directory);
      }
    }

    return file;
  }

  Future<File> _createFile(int index) async {
    final result = File('$_dirPath/file$index.log');
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
