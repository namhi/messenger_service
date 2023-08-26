//@dart=2.12
import 'package:flutter/cupertino.dart';

/// Tất cả các gói tin Message sử dụng  trong Messenger Service đều phải extends class này.
class MessageBase {
  const MessageBase({
    this.token,
    this.sender,
    this.receiverType,
    this.senderType,
    this.message,
  });

  ///The listener can base on [token] to filter messages they want to receive.
  final String? token;

  ///Sender of this message.
  ///
  ///Be careful when using it because maybe sender class is not dispose.
  final Object? sender;

  /// Type of class want to notify to.
  final Type? receiverType;

  /// Type of sender. Maybe using it to filter the messages they want to receive.
  final Type? senderType;

  final String? message;

  @override
  String toString() {
    return '$runtimeType(sender: $senderType, receiver: $receiverType, token: $token)';
  }
}
