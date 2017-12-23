import 'dart:html';

String incrementerSocket(dynamic data, [WebSocket ws]) {
  final int ret = int.parse(data) + 1;
  return ret.toString();
}
