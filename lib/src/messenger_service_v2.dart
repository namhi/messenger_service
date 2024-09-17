import 'dart:developer';

import 'package:messenger_service/messenger_service.dart';

class MessengerService {
  MessengerService._();
  static MessengerService instance = MessengerService._();

  /// you can use MessengerService.instance or MessengerService.i
  static MessengerService get i => instance;

  bool _showDebugLog = true;
  set showDebugLog(bool value) {
    _showDebugLog = value;
  }

  void _log(String message) {
    if (_showDebugLog) {
      log(
        message,
        name: 'MessengerService',
      );
    }
  }

  void send<T extends MessageBase>(T data) {
    _log('send<${data.runtimeType}>($data)');
  }

  void register<T extends MessageBase>() {
    _log('register<$T>()');
  }
}
