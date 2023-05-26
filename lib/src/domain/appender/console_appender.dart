import 'package:flutter/foundation.dart';
import 'package:logging_collector/src/domain/appender/logger_appender.dart';

class ConsoleAppender implements LoggerAppender {
  @override
  Future<void> append(String log) async {
    debugPrint(log);
  }
}