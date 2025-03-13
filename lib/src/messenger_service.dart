import 'dart:async';

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
  final List<MessengerSubscriptionInfo> _subscriptions =
      <MessengerSubscriptionInfo>[];

  List<MessengerSubscriptionInfo> get subscriptions => _subscriptions;

  bool isRegister<T>() {
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
    final messengerSubscriptions = _messengerSubject.whereType<T>().listen(
      (T event) {
        observer.onMessage(event, receiver);
        onMessage.call(event);
      },
    );
    _subscriptions.add(
      MessengerSubscriptionInfo(
        receiver: receiver,
        subscription: messengerSubscriptions,
        messageFunction: onMessage,
        token: token,
        registerType: T,
      ),
    );
    send<MessengerObserverMessage>(
      MessengerObserverMessage(
        sender: this,
        event: MessengerEvent.register,
        receiver: receiver,
        receiverToken: token,
        registerType: T,
      ),
    );
  }

  @mustCallSuper
  Future<void> dispose() async {
    for (final sub in _subscriptions) {
      await sub.subscription.cancel();
      _log('Dispose: ${sub.subscription} in ${sub.receiver.runtimeType}');
    }
    _messengerSubject.close();
  }
}

class MessengerSubscriptionInfo {
  MessengerSubscriptionInfo({
    required this.receiver,
    required this.subscription,
    required this.messageFunction,
    this.token,
    required this.registerType,
  });

  final Object receiver;
  final StreamSubscription<MessageBase> subscription;
  Function messageFunction;
  final String? token;
  final Type registerType;
}
