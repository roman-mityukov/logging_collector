import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging_collector/logging_collector.dart';
import 'package:logging_collector/src/ui/logging_collector_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../test_utils.dart';
import 'logging_collector_bloc_test.mocks.dart';

@GenerateMocks([LogsSharingDelegate])
Future<void> main() async {
  const log = 'someLog';
  final String dirPath = '${Directory.systemTemp.path}/logs';
  late Directory directory;
  late LogsSharingDelegate sharingDelegate;
  late LoggingCollectorConfig config;
  late LoggingCollectorBloc bloc;

  setUp(
    () {
      directory = Directory(dirPath);
      directory.createSync(recursive: true);
      sharingDelegate = MockLogsSharingDelegate();
      config = LoggingCollectorConfig(dirPath, sharingDelegate);
      bloc = LoggingCollectorBloc(config);
    },
  );

  tearDown(() {
    directory.deleteSync(recursive: true);
  });

  group(
    'DeleteAllLogsEvent',
    () {
      blocTest(
        'GIVEN not empty log file '
        'WHEN delete event'
        'THEN logs directory is empty',
        build: () {
          final file = File('$dirPath/file.log');
          file.createSync();

          file.writeAsStringSync(log);

          final fileList = getFiles(directory);
          expect(fileList.isEmpty, false);

          return bloc;
        },
        act: (bloc) => bloc.add(DeleteAllLogsEvent()),
        expect: () => [PendingActionState()],
        verify: (bloc) {
          final fileList = getFiles(directory);
          expect(fileList.isEmpty, true);
        },
      );

      blocTest(
        'GIVEN empty logs directory '
        'WHEN delete event'
        'THEN PendingActionState is emitted',
        build: () {
          return bloc;
        },
        act: (bloc) => bloc.add(DeleteAllLogsEvent()),
        expect: () => [PendingActionState()],
      );
    },
  );

  group(
    'ShareAllLogsEvent',
    () {
      blocTest(
        'GIVEN not empty log file '
        'WHEN share event'
        'THEN sharing delegate is called',
        build: () {
          final file = File('$dirPath/file.log');
          file.createSync();

          file.writeAsStringSync(log);

          return bloc;
        },
        act: (bloc) => bloc.add(ShareAllLogsEvent()),
        expect: () => [PendingActionState()],
        verify: (_) => verify(sharingDelegate.share()).called(1),
      );

      blocTest(
        'GIVEN no logs '
        'WHEN share event '
        'THEN sharing delegate is not called',
        build: () {
          return bloc;
        },
        act: (bloc) => bloc.add(ShareAllLogsEvent()),
        expect: () => [AbsentLogsState(config), PendingActionState()],
        verify: (bloc) => verifyNever(sharingDelegate.share()),
      );
    },
  );

  group(
    'ShowLatestLogsEvent',
    () {
      blocTest(
        'GIVEN not empty log file '
        'WHEN ShowLatestLogsEvent '
        'THEN emitted state with log',
        build: () {
          final file = File('$dirPath/file.log');
          file.createSync();
          file.writeAsStringSync(log);

          final file1 = File('$dirPath/file1.log');
          file1.createSync();
          file1.writeAsStringSync('some other log in file1');

          return bloc;
        },
        act: (bloc) => bloc.add(ShowLatestLogsEvent()),
        expect: () => [ShowLatestLogsState(log), PendingActionState()],
      );

      blocTest(
        'GIVEN empty log file '
        'WHEN ShowLatestLogsEvent '
        'THEN emitted state with log',
        build: () {
          return bloc;
        },
        act: (bloc) => bloc.add(ShowLatestLogsEvent()),
        expect: () => [AbsentLogsState(config), PendingActionState()],
      );
    },
  );
}
