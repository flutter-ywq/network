import 'package:flutter_test/flutter_test.dart';

import 'package:network/network.dart';

void main() {
  test('adds one to input values', () {
    Request request = Request();
    expect(request.toString(), 3);
    expect(() => request.toString(), throwsNoSuchMethodError);
  });
}
