// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviewer_stat.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewerStatCWProxy {
  ReviewerStat login(String login);

  ReviewerStat rereview(int rereview);

  ReviewerStat dismissed(int dismissed);

  ReviewerStat manual(int manual);

  ReviewerStat repos(List<String> repos);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewerStat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewerStat(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewerStat call({
    String login,
    int rereview,
    int dismissed,
    int manual,
    List<String> repos,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewerStat.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewerStat.copyWith.fieldName(...)`
class _$ReviewerStatCWProxyImpl implements _$ReviewerStatCWProxy {
  const _$ReviewerStatCWProxyImpl(this._value);

  final ReviewerStat _value;

  @override
  ReviewerStat login(String login) => this(login: login);

  @override
  ReviewerStat rereview(int rereview) => this(rereview: rereview);

  @override
  ReviewerStat dismissed(int dismissed) => this(dismissed: dismissed);

  @override
  ReviewerStat manual(int manual) => this(manual: manual);

  @override
  ReviewerStat repos(List<String> repos) => this(repos: repos);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewerStat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewerStat(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewerStat call({
    Object? login = const $CopyWithPlaceholder(),
    Object? rereview = const $CopyWithPlaceholder(),
    Object? dismissed = const $CopyWithPlaceholder(),
    Object? manual = const $CopyWithPlaceholder(),
    Object? repos = const $CopyWithPlaceholder(),
  }) {
    return ReviewerStat(
      login: login == const $CopyWithPlaceholder()
          ? _value.login
          // ignore: cast_nullable_to_non_nullable
          : login as String,
      rereview: rereview == const $CopyWithPlaceholder()
          ? _value.rereview
          // ignore: cast_nullable_to_non_nullable
          : rereview as int,
      dismissed: dismissed == const $CopyWithPlaceholder()
          ? _value.dismissed
          // ignore: cast_nullable_to_non_nullable
          : dismissed as int,
      manual: manual == const $CopyWithPlaceholder()
          ? _value.manual
          // ignore: cast_nullable_to_non_nullable
          : manual as int,
      repos: repos == const $CopyWithPlaceholder()
          ? _value.repos
          // ignore: cast_nullable_to_non_nullable
          : repos as List<String>,
    );
  }
}

extension $ReviewerStatCopyWith on ReviewerStat {
  /// Returns a callable class that can be used as follows: `instanceOfReviewerStat.copyWith(...)` or like so:`instanceOfReviewerStat.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewerStatCWProxy get copyWith => _$ReviewerStatCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewerStat _$ReviewerStatFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReviewerStat', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'login',
          'rereview',
          'dismissed',
          'manual',
          'repos',
        ],
      );
      final val = ReviewerStat(
        login: $checkedConvert('login', (v) => v as String),
        rereview: $checkedConvert('rereview', (v) => (v as num).toInt()),
        dismissed: $checkedConvert('dismissed', (v) => (v as num).toInt()),
        manual: $checkedConvert('manual', (v) => (v as num).toInt()),
        repos: $checkedConvert(
          'repos',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReviewerStatToJson(ReviewerStat instance) =>
    <String, dynamic>{
      'login': instance.login,
      'rereview': instance.rereview,
      'dismissed': instance.dismissed,
      'manual': instance.manual,
      'repos': instance.repos,
    };
