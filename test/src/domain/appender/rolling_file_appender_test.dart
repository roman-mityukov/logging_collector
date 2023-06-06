import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging_collector/logging_collector.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_utils.dart';
import 'rolling_file_appender_test.mocks.dart';

@GenerateMocks([LoggingAppenderErrorHandler])
void main() {
  final String dirPath = '${Directory.systemTemp.path}/logs';
  const String log = 'someLog';
  const fileMaxSize = 10;
  const fileMaxCount = 3;
  const testDuration = Duration(milliseconds: 100);

  late RollingFileAppender defaultRollingFileAppender;
  late Directory directory;

  setUpAll(() {
    defaultRollingFileAppender = RollingFileAppender(
      directoryPath: dirPath,
      fileMaxSize: fileMaxSize,
      fileMaxCount: fileMaxCount,
    );
  });

  setUp(
    () {
      directory = Directory(dirPath);
      directory.createSync(recursive: true);
    },
  );

  tearDown(() {
    directory.deleteSync(recursive: true);
  });

  test(
    'GIVEN new RollingFileAppender, '
    'WHEN call append, '
    'THEN new file created',
    () async {
      await defaultRollingFileAppender.append(log);

      await Future.delayed(testDuration);

      final file = File('$dirPath/file.log');

      expect(file.existsSync(), true);

      final string = file.readAsStringSync();

      expect(string, log);
    },
  );

  test(
    'GIVEN new RollingFileAppender, '
    'WHEN call append, '
    'THEN file contains valid log',
    () async {
      await defaultRollingFileAppender.append(log);

      await Future.delayed(testDuration);

      final file = File('$dirPath/file.log');
      final string = file.readAsStringSync();

      expect(string, log);
    },
  );

  test(
    'GIVEN new RollingFileAppender and directory with invalid path, '
    'WHEN call append, '
    'THEN append throws state error',
    () async {
      final errorHandler = MockLoggingAppenderErrorHandler();

      final rollingFileAppender = RollingFileAppender(
        directoryPath: 'generated/invalid',
        fileMaxSize: fileMaxSize,
        fileMaxCount: fileMaxCount,
        errorHandler: errorHandler,
      );

      rollingFileAppender.append(log);

      await Future.delayed(testDuration);

      verify(errorHandler.call(argThat(isA<StateError>()), null));
    },
  );

  test(
    'GIVEN new RollingFileAppender and log greater than fileMaxSize, '
    'WHEN call append, '
    'THEN append throws argument error',
    () async {
      final log = getRandomString(fileMaxSize * 2);

      final errorHandler = MockLoggingAppenderErrorHandler();

      final rollingFileAppender = RollingFileAppender(
        directoryPath: dirPath,
        fileMaxSize: fileMaxSize,
        fileMaxCount: fileMaxCount,
        errorHandler: errorHandler,
      );
      rollingFileAppender.append(log);

      await Future.delayed(testDuration);

      verify(errorHandler.call(argThat(isA<ArgumentError>()), null));
    },
  );

  test(
    'GIVEN new RollingFileAppender, '
    'WHEN logs are greater than fileMaxSize, '
    'THEN second file will be created',
    () async {
      const log0 = log;
      final log1 = getRandomString(fileMaxSize);

      await defaultRollingFileAppender.append(log0);
      await defaultRollingFileAppender.append(log1);

      await Future.delayed(testDuration);

      List<File> files = getFiles(directory);

      expect(files.length, 2);
      expect(files.first.path.contains('file'), true);
      expect(files.last.path.contains('file1'), true);
      expect(files.first.readAsStringSync(), log1);
      expect(files.last.readAsStringSync(), log0);
    },
  );

  test(
    'GIVEN new RollingFileAppender, '
    'WHEN logs are greater than fileMaxSize, '
    'THEN file count is equal to fileMaxCount',
    () async {
      final bigLog = getRandomString(fileMaxSize);
      await defaultRollingFileAppender.append(bigLog);
      await defaultRollingFileAppender.append(bigLog);
      await defaultRollingFileAppender.append(bigLog);
      await defaultRollingFileAppender.append(bigLog);

      await Future.delayed(testDuration);

      List<FileSystemEntity> fileList = directory.listSync();

      expect(fileList.length, fileMaxCount);
    },
  );

  test(
    'GIVEN new RollingFileAppender, '
    'WHEN logs are greater than fileMaxSize, '
    'THEN first file contains latest logs',
    () async {
      final bigLog1 = getRandomString(fileMaxSize);
      final bigLog2 = getRandomString(fileMaxSize);
      final bigLog3 = getRandomString(fileMaxSize);
      final bigLog4 = getRandomString(fileMaxSize);

      await defaultRollingFileAppender.append(bigLog1);
      await defaultRollingFileAppender.append(bigLog2);
      await defaultRollingFileAppender.append(bigLog3);

      await Future.delayed(testDuration);

      List<File> files = getFiles(directory);
      expect(files[0].readAsStringSync(), bigLog3);
      expect(files[1].readAsStringSync(), bigLog2);
      expect(files[2].readAsStringSync(), bigLog1);

      await defaultRollingFileAppender.append(bigLog4);
      await Future.delayed(testDuration);

      files = getFiles(directory);
      expect(files[0].readAsStringSync(), bigLog4);
      expect(files[1].readAsStringSync(), bigLog3);
      expect(files[2].readAsStringSync(), bigLog2);
    },
  );

  test(
    'GIVEN RollingFileAppender with fileMaxCount = 1, '
    'WHEN logs are greater than fileMaxSize, '
    'THEN first file contains latest logs',
    () async {
      final rollingFileAppender = RollingFileAppender(
        directoryPath: dirPath,
        fileMaxCount: 1,
        fileMaxSize: fileMaxSize,
      );

      final bigLog1 = getRandomString(fileMaxSize);
      final bigLog2 = getRandomString(fileMaxSize);

      await rollingFileAppender.append(bigLog1);
      await rollingFileAppender.append(bigLog2);

      await Future.delayed(testDuration);

      List<File> files = getFiles(directory);
      expect(files.length, 1);
      expect(files[0].readAsStringSync(), bigLog2);
    },
  );
}
