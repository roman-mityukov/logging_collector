library logging_collector;

import 'package:equatable/equatable.dart';
import 'package:logging_collector/src/domain/sharing/logs_sharing_delegate.dart';

export 'src/ui/logging_collector_widget.dart';
export 'src/domain/appender/logger_appender.dart';
export 'src/domain/appender/logger_appender_error_handler.dart';
export 'src/domain/appender/rolling_file_appender.dart';
export 'src/domain/sharing/logs_sharing_delegate.dart';

class LoggingCollectorConfig extends Equatable {
  final String logsDirectoryPath;
  final LogsSharingDelegate sharingDelegate;

  const LoggingCollectorConfig(this.logsDirectoryPath, this.sharingDelegate);

  @override
  List<Object?> get props => [logsDirectoryPath];
}
