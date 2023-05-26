import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging_collector/logging_collector.dart';

part 'logging_collector_event.dart';

part 'logging_collector_state.dart';

class LoggingCollectorBloc
    extends Bloc<LoggingCollectorEvent, LoggingCollectorState> {
  final String _directoryPath;
  final ShareCallback _shareCallback;

  LoggingCollectorBloc(
    this._directoryPath,
    this._shareCallback,
  ) : super(PendingActionState()) {
    on<ClearAllEvent>(_onClearAllEvent);
    on<ShareEvent>(_onShareEvent);
    on<ShowEvent>(_onShowEvent);
  }

  Future<void> _onClearAllEvent(
    ClearAllEvent event,
    Emitter<LoggingCollectorState> emitter,
  ) async {
    final file = File(_directoryPath);
    if (file.existsSync()) {
      file.deleteSync();
    } else {
      emitter(AbsentFileState());
    }
  }

  Future<void> _onShareEvent(
    ShareEvent event,
    Emitter<LoggingCollectorState> emitter,
  ) async {
    await _shareCallback.call();
  }

  Future<void> _onShowEvent(
    ShowEvent event,
    Emitter<LoggingCollectorState> emitter,
  ) async {
    final directory = Directory(_directoryPath);
    List<FileSystemEntity> fileList = directory.listSync();
    fileList.sort((a, b) {
      return a.path.compareTo(b.path);
    });

    final file = fileList.whereType<File>().toList().first;
    if (file.existsSync()) {
      emitter(ShowLogsState(file.readAsStringSync()));
      emitter(PendingActionState());
    } else {
      emitter(AbsentFileState());
    }
  }
}
