import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging_collector/logging_collector.dart';

part 'logging_collector_event.dart';

part 'logging_collector_state.dart';

class LoggingCollectorBloc
    extends Bloc<LoggingCollectorEvent, LoggingCollectorState> {
  final LoggingCollectorConfig _config;

  LoggingCollectorBloc(this._config) : super(PendingActionState()) {
    on<DeleteAllLogsEvent>(_onDeleteAllLogsEvent);
    on<ShareAllLogsEvent>(_onShareAllLogsEvent);
    on<ShowLatestLogsEvent>(_onShowLatestLogsEvent);
  }

  Future<void> _onDeleteAllLogsEvent(
    DeleteAllLogsEvent event,
    Emitter<LoggingCollectorState> emitter,
  ) async {
    final fileList = _getFileList();
    for (final file in fileList) {
      file.deleteSync();
    }

    emitter(PendingActionState());
  }

  Future<void> _onShareAllLogsEvent(
    ShareAllLogsEvent event,
    Emitter<LoggingCollectorState> emitter,
  ) async {
    final fileList = _getFileList();

    if (fileList.isNotEmpty) {
      await _config.sharingDelegate.share();
    } else {
      emitter(AbsentLogsState(_config));
    }

    emitter(PendingActionState());
  }

  Future<void> _onShowLatestLogsEvent(
    ShowLatestLogsEvent event,
    Emitter<LoggingCollectorState> emitter,
  ) async {
    final fileList = _getFileList();

    if (fileList.isNotEmpty) {
      fileList.sort((a, b) {
        return a.path.compareTo(b.path);
      });
      final file = fileList.first;
      final bytes = file.readAsBytesSync();
      final string = String.fromCharCodes(bytes);
      emitter(ShowLatestLogsState(string));
    } else {
      emitter(AbsentLogsState(_config));
    }

    emitter(PendingActionState());
  }

  List<File> _getFileList() {
    final Directory directory = Directory(_config.logsDirectoryPath);
    final List<File> fileList;

    if (directory.existsSync()) {
      fileList = directory.listSync().whereType<File>().toList();
    } else {
      fileList = [];
    }

    return fileList;
  }
}
