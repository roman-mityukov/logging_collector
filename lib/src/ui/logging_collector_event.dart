part of 'logging_collector_bloc.dart';

sealed class LoggingCollectorEvent {}

class ClearAllEvent implements LoggingCollectorEvent {}

class ShareEvent implements LoggingCollectorEvent {}

class ShowEvent implements LoggingCollectorEvent {}