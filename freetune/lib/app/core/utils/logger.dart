class Logger {
  static void log(String message) {
    // Simple logger for now, can integrate a more robust logging solution
    print('[FreeTune LOG]: $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[FreeTune ERROR]: $message');
    if (error != null) {
      print('Error: $error');
    }
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }
}
