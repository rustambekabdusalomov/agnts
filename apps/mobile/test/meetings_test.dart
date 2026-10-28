import 'package:agnts_mobile/features/meetings/meetings_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('meeting codes are read as people type or paste them', () {
    expect(parseMeetingCode('abc-defg-hij'), 'abc-defg-hij');
    expect(parseMeetingCode(' ABCDEFGHIJ '), 'abc-defg-hij');
    expect(parseMeetingCode('https://app.agnts.uz/m/abc-defg-hij?i=token'), 'abc-defg-hij');
    expect(parseMeetingCode('abc-defg-hi1'), isNull);
    expect(parseMeetingCode('abc'), isNull);
  });

  test('times from the start of a call', () {
    expect(meetingOffset(0), '0:00');
    expect(meetingOffset(61000), '1:01');
    expect(meetingOffset(3725000), '1:02:05');
  });
}
