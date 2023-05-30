import 'dart:collection';
import 'dart:io';

import 'package:logging_collector/src/domain/appender/logger_appender.dart';
import 'package:logging_collector/src/domain/appender/logger_appender_error_handler.dart';

class RollingFileAppender implements LoggerAppender {
  final String _directoryPath;
  final LoggingAppenderErrorHandler? _errorHandler;
  final int _fileMaxCount;
  final int _fileMaxSize;
  bool _isExecuting = false;
  final Queue<String> _queue = Queue();

  RollingFileAppender({
    required String directoryPath,
    required int fileMaxCount,
    required int fileMaxSize,
    LoggingAppenderErrorHandler? errorHandler,
  })  : _directoryPath = directoryPath,
        _errorHandler = errorHandler,
        _fileMaxSize = fileMaxSize,
        _fileMaxCount = fileMaxCount,
        assert(directoryPath.isNotEmpty),
        assert(fileMaxCount > 0),
        assert(fileMaxSize > 0);

  @override
  Future<void> append(String log) async {
    _queue.addFirst(log);
    _execute();
  }

  Future<void> _addLogToFile(String log) async {
    try {
      final directory = Directory(_directoryPath);

      if (!(await directory.exists())) {
        _errorHandler?.call(
          StateError('Error! Directory $_directoryPath does not exist'),
          null,
        );
      }

      final logBytes = log.codeUnits;
      final logBytesLength = logBytes.length;

      if (logBytesLength > _fileMaxSize) {
        _errorHandler?.call(ArgumentError('Error! Log is too long'), null);
      }

      final file = await _getFile(directory, logBytesLength);

      await file.writeAsBytes(logBytes, mode: FileMode.append);
    } catch (error, stackTrace) {
      _errorHandler?.call(error, stackTrace);
    }
  }

  Future<File> _createFile() async {
    final result = File('$_directoryPath/file.log');
    await result.create(recursive: true);
    return result;
  }

  Future<void> _execute() async {
    if (_isExecuting) return;

    while (_queue.isNotEmpty) {
      _isExecuting = true;
      final task = _queue.removeLast();
      await _addLogToFile(task);
      _isExecuting = false;
    }
  }

  Future<File> _getFile(Directory directory, int logBytesLength) async {
    List<File> fileList = await _getFileListSortedByPath(directory);

    File file;

    if (fileList.isEmpty) {
      file = await _createFile();
    } else {
      file = fileList.first;

      if ((await file.length()) + logBytesLength > _fileMaxSize) {
        await _rollOver(directory);
        file = await _createFile();
        List<File> newFileList = await _getFileListSortedByPath(directory);

        if (newFileList.length > _fileMaxCount) {
          newFileList.last.deleteSync(recursive: true);
        }
      }
    }

    return file;
  }

  Future<List<File>> _getFileListSortedByPath(Directory directory) async {
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

  Future<void> _rollOver(Directory directory) async {
    final files = await _getFileListSortedByPath(directory);

    for (int i = files.length - 1; i >= 0; i--) {
      final file = files[i];
      file.renameSync('$_directoryPath/file${i + 1}.log');
    }
  }
}
