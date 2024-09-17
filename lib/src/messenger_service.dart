import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:messenger_service/messenger_service.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:developer';

/// This is a service using as messenger delivery.
///
/// When using it you must remember to close the stream of listener register.
class MessengerService {
  MessengerService._();
  static MessengerService instance = MessengerService._();

  /// you can use MessengerService.instance or MessengerService.i
  static MessengerService get i => instance;

  final PublishSubject<dynamic> _messengerSubject = PublishSubject<dynamic>();
  MessengerObserver observer = DefaultMessengerObserver();

  bool _showDebugLog = true;
  set showDebugLog(bool value) {
    _showDebugLog = value;
  }

  void send<T extends MessageBase>(T data) {
    _messengerSubject.add(data);
    observer.onSend(data);
  }

  void _log(String message) {
    if (_showDebugLog) {
      log(
        message,
        name: 'MessengerService',
      );
    }
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
    observer.onResiger(receiver, T.toString());
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
        final register = _messengerSubject.toList();
        _log(register.toString());
        observer.onMessage(event, receiver);

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
