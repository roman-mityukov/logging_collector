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
    final directory = Directory(_directoryPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    emitter(PendingActionState());
  }

  Future<void> _onShareEvent(
    ShareEvent event,
    Emitter<LoggingCollectorState> emitter,
  ) async {
    final directory = Directory(_directoryPath);

    if (directory.existsSync()) {
      List<FileSystemEntity> fileList = directory.listSync();
      if (fileList.whereType<File>().toList().isEmpty) {
        emitter(AbsentFileState());
      } else {
        await _shareCallback.call();
      }
    } else {
      emitter(AbsentFileState());
    }
    emitter(PendingActionState());
  }

  Future<void> _onShowEvent(
    ShowEvent event,
    Emitter<LoggingCollectorState> emitter,
  ) async {
    final directory = Directory(_directoryPath);

    if (directory.existsSync()) {
      List<FileSystemEntity> fileList = directory.listSync();
      fileList.sort((a, b) {
        return a.path.compareTo(b.path);
      });

      final file = fileList.whereType<File>().toList().firstOrNull;
      if (file != null && file.existsSync()) {
        emitter(ShowLogsState(file.readAsStringSync()));
      } else {
        emitter(AbsentFileState());
      }
    } else {
      emitter(AbsentFileState());
    }
    emitter(PendingActionState());
  }
}
