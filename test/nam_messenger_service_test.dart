import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_service/messenger_service.dart';

void main() {
  test('adds one to input values', () {});
}

class TestMessage extends MessageBase {
  TestMessage({
    super.message,
    super.sender,
    super.token,
  });
}
