import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:logging_collector/logging_collector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // setup logs directory
  final Directory docsDirectory = await getApplicationDocumentsDirectory();
  final logsDirectoryPath = '${docsDirectory.path}/logs';
  final logsDirectory = Directory(logsDirectoryPath);
  logsDirectory.createSync();

  // create RollingFileAppender, it'll write log messages into logs directory
  final appenders = [
    RollingFileAppender(
      directoryPath: logsDirectoryPath,
      fileMaxSize: 1024 * 1024,
      fileMaxCount: 3,
    ),
  ];

  // setup logging
  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen(
    (LogRecord record) async {
      String log;
      if (record.error != null) {
        log = '${record.level.name}: ${record.time}: ${record.loggerName}:'
            ' ${record.message}: ${record.error}\n'
            'stackTrace\n${record.stackTrace}\n';
      } else {
        log = '${record.level.name}: ${record.time}: ${record.loggerName}:'
            ' ${record.message}\n';
      }

      for (final appender in appenders) {
        await appender.append(log);
      }
    },
  );

  // create logs collector config
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
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _logger = Logger('MyApp');

  @override
  void initState() {
    super.initState();
    Timer.periodic(
      const Duration(seconds: 2),
      (timer) {
        _logger.fine('message id ${Random().nextDouble()}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Placeholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
                builder: (context) => LoggingCollectorWidget(context.read())),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
