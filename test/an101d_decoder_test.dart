import 'package:flutter_test/flutter_test.dart';

import 'package:an101d_decoder/an101d_decoder.dart';

void main() {
  test('Checks decoded data', () {
    final an101d = new AN101D('oIDke2+Ctgu4JA==');
    expect(an101d.data['is_parked'], false);
  });
}
