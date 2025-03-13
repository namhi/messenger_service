import 'package:freezed_annotation/freezed_annotation.dart';

/// Tất cả các gói tin Message sử dụng  trong Messenger Service đều phải extends class này.
abstract class MessageBase {
  MessageBase({
    required this.sender,
    this.token,
    this.metadata,
  });

  final Object sender;
  final String? token;
  final Map<String, dynamic>? metadata;

  @override
  String toString() {
    return '$runtimeType(sender: $sender, token: $token)';
  }
}

@freezed
class MessengerObserverMessage extends MessageBase {
  MessengerObserverMessage({
    required super.sender,
    super.token,
    required this.event,
    this.receiver,
    this.receiverToken,
    this.registerType,
    this.registerToken,
  });
  final MessengerEvent event;
  final Object? receiver;
  final String? receiverToken;
  final Type? registerType;
  final String? registerToken;
}

enum MessengerEvent {
  register,
  messageSend,
  unregister,
}
