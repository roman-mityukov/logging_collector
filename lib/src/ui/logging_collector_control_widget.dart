import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging_collector/src/ui/logging_collector_bloc.dart';
import 'package:logging_collector/src/ui/logging_details_widget.dart';

class LoggingCollectorControlWidget extends StatelessWidget {
  const LoggingCollectorControlWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoggingCollectorBloc, LoggingCollectorState>(
      buildWhen: (previous, current) {
        return current is PendingActionState;
      },
      builder: (context, state) {
        if (state is PendingActionState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Logging',
                  style: Theme.of(context).textTheme.titleLarge!,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<LoggingCollectorBloc>().add(ShowLatestLogsEvent()),
                  child: const Text('Show last logs'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      context.read<LoggingCollectorBloc>().add(ShareAllLogsEvent()),
                  child: const Text('Share logs'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      context.read<LoggingCollectorBloc>().add(DeleteAllLogsEvent()),
                  child: const Text('Clear logs directory'),
                ),
              ],
            ),
          );
        } else {
          throw StateError('Invalid state');
        }
      },
      listenWhen: (previous, current) {
        return current is AbsentLogsState || current is ShowLatestLogsState;
      },
      listener: (context, state) {
        if (state is AbsentLogsState) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(
                  'There is no log files in ${state.config.logsDirectoryPath}',
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else if (state is ShowLatestLogsState) {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => BlocProvider<LoggingCollectorBloc>.value(
                value: context.read<LoggingCollectorBloc>(),
                child: LoggingDetailsWidget(state.data),
              ),
            ),
          );
        } else {
          throw StateError('Invalid state');
        }
      },
    );
  }
}
