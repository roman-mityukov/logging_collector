library logging_collector;

export 'src/ui/logging_collector_widget.dart';
export 'src/domain/appender/logger_appender.dart';
export 'src/domain/appender/console_appender.dart';
export 'src/domain/appender/rolling_file_appender.dart';

typedef ShareCallback = Future<void> Function();

class LoggingCollector {
  static late String _logsDirectoryPath;
  static late ShareCallback _shareCallback;

  static void init({
    required String logsDirectoryPath,
    required ShareCallback shareCallback,
  }) {
    _logsDirectoryPath = logsDirectoryPath;
    _shareCallback = shareCallback;
  }

  static String get logsDirectoryPath => _logsDirectoryPath;
  static ShareCallback get shareCallback => _shareCallback;

  LoggingCollector._();
}
