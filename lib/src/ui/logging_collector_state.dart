part of 'logging_collector_bloc.dart';

sealed class LoggingCollectorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PendingActionState extends LoggingCollectorState {}

class AbsentLogsState extends LoggingCollectorState {
  final LoggingCollectorConfig config;

  AbsentLogsState(this.config);

  @override
  List<Object?> get props => [config];
}

class ShowLatestLogsState extends LoggingCollectorState {
  final String data;

  ShowLatestLogsState(this.data);
}