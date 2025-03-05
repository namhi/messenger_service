import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:messenger_service/messenger_service.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:developer';

/// This is a service using as messenger delivery.
class MessengerService {
  MessengerService._();
  static MessengerService instance = MessengerService._();

  /// you can use MessengerService.instance or MessengerService.i
  static MessengerService get i => instance;

  final PublishSubject<MessageBase> _messengerSubject =
      PublishSubject<MessageBase>();
  MessengerObserver observer = DefaultMessengerObserver();

  /// Save all subscriptions to close when dispose.
  static final List<MessengerSubscriptionInfo> _subscriptions =
      <MessengerSubscriptionInfo>[];

  static bool isRegister<T>() {
    final register = _subscriptions.whereType<StreamSubscription<T>>().toList();
    return register.isNotEmpty;
  }

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

  /// Unregister message listener from [receiver]
  ///
  /// [onMessage] is optional, if you want to unregister a specific message listener.
  void unregister<T extends MessageBase>(
    Object receiver, {
    Function? onMessage,
  }) {
    final register = _subscriptions
        .where(
          (e) =>
              e.subscription is StreamSubscription<T> &&
              receiver == e.receiver &&
              (onMessage == null || e.messageFunction == onMessage),
        )
        .toList();

    for (final sub in register) {
      sub.subscription.cancel();
      _subscriptions.remove(sub);
      _log('Unregister: ${sub.subscription} in ${receiver.runtimeType}');
    }
  }

  /// Register message listener from [receiver]
  void register<T extends MessageBase>(
    Object receiver,
    void Function(T message) onMessage, {
    String? token,
  }) {
    observer.onResiger(receiver, T.toString());
    final messengerSubscriptions = _messengerSubject
        .where(
      (event) => event is T,
    )
        .listen(
      (event) {
        observer.onMessage(event, receiver);
        onMessage.call(event as T);
      },
    );
    _subscriptions.add(MessengerSubscriptionInfo(
      receiver: receiver,
      subscription: messengerSubscriptions,
      messageFunction: onMessage,
    ));
  }

  @mustCallSuper
  void dispose() {
    _messengerSubject.close();
  }
}

class MessengerSubscriptionInfo {
  MessengerSubscriptionInfo({
    required this.receiver,
    required this.subscription,
    required this.messageFunction,
  });

  final Object receiver;
  final StreamSubscription<MessageBase> subscription;
  Function messageFunction;
}
