part of 'logging_collector_bloc.dart';

sealed class LoggingCollectorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PendingActionState extends LoggingCollectorState {}

class AbsentFileState extends LoggingCollectorState {}

class ShowLogsState extends LoggingCollectorState {
  final String data;

  ShowLogsState(this.data);
}