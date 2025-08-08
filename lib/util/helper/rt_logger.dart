String rtLoggerTag = 'Retailer-Logger';
String logs = '[$rtLoggerTag] - Starting at ${DateTime.now()}';

Future<void> rtDebug(dynamic message, {String? tag}) async {
  String log = "\n[$rtLoggerTag] ${tag == null ? '' : '($tag)'}: $message";
  print(log);
  logs += log;
}
