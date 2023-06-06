part of 'logging_collector_bloc.dart';

sealed class LoggingCollectorEvent {}

class DeleteAllLogsEvent implements LoggingCollectorEvent {}

class ShareAllLogsEvent implements LoggingCollectorEvent {}

class ShowLatestLogsEvent implements LoggingCollectorEvent {}