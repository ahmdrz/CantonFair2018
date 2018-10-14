import 'dart:async';

import 'package:flutter/services.dart';

const _channel = const MethodChannel('net.zibaei.flutter/open_directory');

Future<dynamic> openDirectory(String uriString) {
  return _channel.invokeMethod('openDirectory', {"uri": uriString});
}

Future<bool> canOpen(String uriString) async {
  if (uriString == null) return false;
  return await _channel.invokeMethod('canOpen', {"uri": uriString});
}
