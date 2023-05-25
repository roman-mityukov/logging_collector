import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging_collector/logging_collector.dart';
import 'package:logging_collector/src/ui/logging_collector_bloc.dart';
import 'package:logging_collector/src/ui/logging_collector_control_widget.dart';

class LoggingCollectorRunnerWidget extends StatelessWidget {
  const LoggingCollectorRunnerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return LoggingCollectorBloc(
          LoggingCollector.logsDirectoryPath,
          LoggingCollector.shareCallback,
        );
      },
      child: const LoggingCollectorControlWidget(),
    );
  }
}
