abstract interface class LoggerAppender {
  Future<void> append(String log);
}