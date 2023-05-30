library logging_collector;

import 'package:logging_collector/src/domain/sharing/sharing_callback.dart';

export 'src/ui/logging_collector_widget.dart';
export 'src/domain/appender/logger_appender.dart';
export 'src/domain/appender/logger_appender_error_handler.dart';
export 'src/domain/appender/rolling_file_appender.dart';
export 'src/domain/sharing/sharing_callback.dart';

class LoggingCollectorConfig {
  final String logsDirectoryPath;
  final SharingCallback sharingCallback;

  LoggingCollectorConfig(this.logsDirectoryPath, this.sharingCallback);
}
