import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging_collector/logging_collector.dart';

import 'test_utils.dart';

void main() {
  final String dirPath = '${Directory.systemTemp.path}/logs';
  const String log = 'someLog';
  const fileMaxSize = 10;
  const fileMaxCount = 3;

  late RollingFileAppender defaultRollingFileAppender;
  late Directory directory;

  setUpAll(() {
    defaultRollingFileAppender = RollingFileAppender(
      dirPath: dirPath,
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

      await Future.delayed(const Duration(seconds: 1));

      final file = File('$dirPath/file0.log');

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

      await Future.delayed(const Duration(seconds: 1));

      final file = File('$dirPath/file0.log');
      final string = file.readAsStringSync();

      expect(string, log);
    },
  );

  // test(
  //   'GIVEN new RollingFileAppender and directory with invalid path, '
  //   'WHEN call append, '
  //   'THEN append throws state error',
  //   () {
  //     final rollingFileAppender = RollingFileAppender(
  //       dirPath: 'generated/invalid',
  //       fileMaxSize: fileMaxSize,
  //       fileMaxCount: fileMaxCount,
  //     );
  //     expect(() => rollingFileAppender.append(log), throwsStateError);
  //   },
  // );
  //
  // test(
  //   'GIVEN new RollingFileAppender and log greater than fileMaxSize, '
  //   'WHEN call append, '
  //   'THEN append throws argument error',
  //   () {
  //     final log = getRandomString(fileMaxSize * 2);
  //     expect(() => defaultRollingFileAppender.append(log), throwsArgumentError);
  //   },
  // );

  test(
    'GIVEN new RollingFileAppender, '
    'WHEN logs are greater than fileMaxSize, '
    'THEN second file will be created',
    () async {
      const log0 = log;
      final log1 = getRandomString(fileMaxSize);

      await defaultRollingFileAppender.append(log0);
      await defaultRollingFileAppender.append(log1);

      await Future.delayed(const Duration(seconds: 1));

      List<File> files = getFiles(directory);

      expect(files.length, 2);
      expect(files.first.path.contains('file0'), true);
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

      await Future.delayed(const Duration(seconds: 1));

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

      await Future.delayed(const Duration(seconds: 1));

      List<File> files = getFiles(directory);
      expect(files[0].readAsStringSync(), bigLog3);
      expect(files[1].readAsStringSync(), bigLog2);
      expect(files[2].readAsStringSync(), bigLog1);

      await defaultRollingFileAppender.append(bigLog4);
      await Future.delayed(const Duration(seconds: 1));

      files = getFiles(directory);
      expect(files[0].readAsStringSync(), bigLog4);
      expect(files[1].readAsStringSync(), bigLog3);
      expect(files[2].readAsStringSync(), bigLog2);
    },
  );
}
