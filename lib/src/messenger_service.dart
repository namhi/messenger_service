import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'data_message_base.dart';

/// This is a service using as messenger delivery.
///
/// When using it you must remember to close the stream of listener register.
class MessengerService {
  MessengerService._();
  static MessengerService instance = MessengerService._();

  /// you can use MessengerService.instance or MessengerService.i
  static MessengerService get i => instance;

  final Logger _logger = Logger();
  final PublishSubject<dynamic> _messengerSubject = PublishSubject<dynamic>();

  void send<T extends MessageBase>(T data) {
    _messengerSubject.add(data);
    _logger.i('on send(data: $data)');
  }

  /// Register message listener from [receiver]
  StreamSubscription register<T extends MessageBase>(
    Object receiver,
    void Function(T message) onMessage, {
    Object? token,
    Object? sender,
    Object? senderType,
    List<Object>? tokens,
    List<Object>? senderTypes,
  }) {
    _logger.i('${receiver.runtimeType} Registered new Message type $T');

    final senderTokenTemp = tokens ?? <Object>[];
    if (token != null) {
      senderTokenTemp.add(token);
    }
    final senderTypeTemp = senderTypes ?? [];
    if (senderType != null) {
      senderTypeTemp.add(senderType);
    }

    final messengerSubscriptions = _messengerSubject
        .where((dynamic event) => event is T)
        .where((dynamic event) =>
            (event as MessageBase).sender == null || event.sender != receiver)
        .where((dynamic event) =>
            senderTokenTemp.isEmpty ||
            senderTokenTemp.contains((event as MessageBase).token))
        .where((dynamic event) =>
            sender == null || sender == (event as MessageBase).sender)
        .where((dynamic event) =>
            senderType == null ||
            senderTypeTemp.contains((event as MessageBase).senderType))
        .listen(
      (dynamic event) {
        _logger.d('On receive message:  (receiver: $receiver, message: $event');
        onMessage.call(event as T);
      },
    );
    return messengerSubscriptions;
  }

  @mustCallSuper
  void dispose() {
    _messengerSubject.close();
  }
}
