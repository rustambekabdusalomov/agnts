import 'package:agnts_api/agnts_api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tickets/preview_shots.dart';

PreviewShot _shot(
  String id, {
  PreviewShotSideEnum side = PreviewShotSideEnum.after,
  PreviewShotViewportEnum viewport = PreviewShotViewportEnum.phone,
}) => PreviewShot(id: id, name: 'Home', route: '/', viewport: viewport, side: side, url: '/tickets/PAY-1/preview/1/shots/$id');

void main() {
  test('pairs after and before shots by id, in the order taken', () {
    final groups = groupShots([
      _shot('home-phone-after'),
      _shot('cart-phone-after'),
      _shot('home-phone-before', side: PreviewShotSideEnum.before),
      _shot('login-phone-before', side: PreviewShotSideEnum.before),
    ]);
    expect(groups.map((g) => g.key), ['home-phone', 'cart-phone', 'login-phone']);
    expect(groups[0].after?.id, 'home-phone-after');
    expect(groups[0].before?.id, 'home-phone-before');
    expect(groups[1].before, isNull);
    expect(groups[2].after, isNull);
    expect(groups[2].any.id, 'login-phone-before');
  });

  test('keeps shots without a side suffix on their own', () {
    final groups = groupShots([_shot('home'), _shot('home-afterwards')]);
    expect(groups.map((g) => g.key), ['home', 'home-afterwards']);
  });

  test('writes the feedback line as the admin panel does', () {
    expect(shotFeedbackLine(_shot('home-phone-after')), '- On screenshot "Home" (phone, /): ');
  });
}
