import 'dart:developer';

abstract class MessengerObserver {
  MessengerObserver();

  /// Called whenever a user register to receive message.
  void onResiger(dynamic receiver, String messageType) {}

  /// Called whenever a user send a message.
  void onSend(data) {}

  /// Called whenever a messsage delivered to a receiver.
  void onMessage(dynamic message, dynamic receiver) {}
}

class DefaultMessengerObserver extends MessengerObserver {
  /// Called whenever a user register to receive message.
  @override
  void onResiger(dynamic receiver, String messageType) {
    _log('register<$messageType>() by <${receiver.runtimeType}>,');
  }

  /// Called whenever a user send a message.
  @override
  void onSend(data) {
    _log('send<${data.runtimeType}>($data)');
  }

  /// Called whenever a messsage delivered to a receiver.
  @override
  void onMessage(dynamic message, dynamic receiver) {
    _log(
        'Deliver message:  (receiver: ${receiver.runtimeType}, message: $message');
  }

  void _log(String message) {
    log(
      message,
      name: 'MessengerService',
    );
  }
}
