# logging_collector

Simple package for logging in files and logs sharing.

Setup logging directory

```dart
import 'package:path_provider/path_provider.dart';

final Directory docsDirectory = await getApplicationDocumentsDirectory();

final logsDirectoryPath = '${docsDirectory.path}/logs';
final logsDirectory = Directory(logsDirectoryPath);
logsDirectory.createSync();
```

create `RollingFileAppender`, it'll write log messages into logs directory

```dart
final appenders = [
  RollingFileAppender(
    directoryPath: logsDirectoryPath,
    fileMaxSize: 1024 * 1024,
    fileMaxCount: 3,
  ),
];
```

use `RollingFileAppender` for logging

```dart
import 'package:logging/logging.dart';

Logger.root.onRecord.listen(
    (LogRecord record) async {
    String log = record.message;
    
    for (final appender in appenders) {
    await appender.append(log);
    }
    },
);
```

create `LoggingCollectorConfig` and run app

```dart
final loggingCollectorConfig = LoggingCollectorConfig(
  logsDirectoryPath,
  _CustomSharingDelegate(logsDirectory),
);

runApp(
    Provider<LoggingCollectorConfig>.value(
    value: loggingCollectorConfig,
    child: const MyApp(),
    ),
);
```

For logs sharing (optional) you can implement `LogsSharingDelegate`. E.g.

```dart
import 'package:archive/archive_io.dart';
class _CustomSharingDelegate implements LogsSharingDelegate {
  final Directory _logsDirectory;

  _CustomSharingDelegate(this._logsDirectory);

  @override
  Future<void> share() async {
    final zipEncoder = ZipFileEncoder();
    final zipPath = '../${_logsDirectory.path}/logs.zip';
    zipEncoder.zipDirectory(
      _logsDirectory,
      filename: zipPath,
    );

    Share.shareXFiles(
      [XFile(zipPath)],
      subject: 'Share',
      text: 'Share logs',
    );
  }
}
```