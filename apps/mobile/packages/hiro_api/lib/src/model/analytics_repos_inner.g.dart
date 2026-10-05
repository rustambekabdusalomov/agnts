// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_repos_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalyticsReposInnerCWProxy {
  AnalyticsReposInner repoId(int repoId);

  AnalyticsReposInner name(String name);

  AnalyticsReposInner kind(String kind);

  AnalyticsReposInner claudeMd(String claudeMd);

  AnalyticsReposInner tickets(int tickets);

  AnalyticsReposInner done(int done);

  AnalyticsReposInner finished(int finished);

  AnalyticsReposInner avgTurns(num avgTurns);

  AnalyticsReposInner hiroMin(num hiroMin);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsReposInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsReposInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsReposInner call({
    int repoId,
    String name,
    String kind,
    String claudeMd,
    int tickets,
    int done,
    int finished,
    num avgTurns,
    num hiroMin,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalyticsReposInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalyticsReposInner.copyWith.fieldName(...)`
class _$AnalyticsReposInnerCWProxyImpl implements _$AnalyticsReposInnerCWProxy {
  const _$AnalyticsReposInnerCWProxyImpl(this._value);

  final AnalyticsReposInner _value;

  @override
  AnalyticsReposInner repoId(int repoId) => this(repoId: repoId);

  @override
  AnalyticsReposInner name(String name) => this(name: name);

  @override
  AnalyticsReposInner kind(String kind) => this(kind: kind);

  @override
  AnalyticsReposInner claudeMd(String claudeMd) => this(claudeMd: claudeMd);

  @override
  AnalyticsReposInner tickets(int tickets) => this(tickets: tickets);

  @override
  AnalyticsReposInner done(int done) => this(done: done);

  @override
  AnalyticsReposInner finished(int finished) => this(finished: finished);

  @override
  AnalyticsReposInner avgTurns(num avgTurns) => this(avgTurns: avgTurns);

  @override
  AnalyticsReposInner hiroMin(num hiroMin) => this(hiroMin: hiroMin);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyticsReposInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyticsReposInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyticsReposInner call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? claudeMd = const $CopyWithPlaceholder(),
    Object? tickets = const $CopyWithPlaceholder(),
    Object? done = const $CopyWithPlaceholder(),
    Object? finished = const $CopyWithPlaceholder(),
    Object? avgTurns = const $CopyWithPlaceholder(),
    Object? hiroMin = const $CopyWithPlaceholder(),
  }) {
    return AnalyticsReposInner(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as String,
      claudeMd: claudeMd == const $CopyWithPlaceholder()
          ? _value.claudeMd
          // ignore: cast_nullable_to_non_nullable
          : claudeMd as String,
      tickets: tickets == const $CopyWithPlaceholder()
          ? _value.tickets
          // ignore: cast_nullable_to_non_nullable
          : tickets as int,
      done: done == const $CopyWithPlaceholder()
          ? _value.done
          // ignore: cast_nullable_to_non_nullable
          : done as int,
      finished: finished == const $CopyWithPlaceholder()
          ? _value.finished
          // ignore: cast_nullable_to_non_nullable
          : finished as int,
      avgTurns: avgTurns == const $CopyWithPlaceholder()
          ? _value.avgTurns
          // ignore: cast_nullable_to_non_nullable
          : avgTurns as num,
      hiroMin: hiroMin == const $CopyWithPlaceholder()
          ? _value.hiroMin
          // ignore: cast_nullable_to_non_nullable
          : hiroMin as num,
    );
  }
}

extension $AnalyticsReposInnerCopyWith on AnalyticsReposInner {
  /// Returns a callable class that can be used as follows: `instanceOfAnalyticsReposInner.copyWith(...)` or like so:`instanceOfAnalyticsReposInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalyticsReposInnerCWProxy get copyWith =>
      _$AnalyticsReposInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsReposInner _$AnalyticsReposInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnalyticsReposInner', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'repoId',
          'name',
          'kind',
          'claudeMd',
          'tickets',
          'done',
          'finished',
          'avgTurns',
          'hiroMin',
        ],
      );
      final val = AnalyticsReposInner(
        repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert('kind', (v) => v as String),
        claudeMd: $checkedConvert('claudeMd', (v) => v as String),
        tickets: $checkedConvert('tickets', (v) => (v as num).toInt()),
        done: $checkedConvert('done', (v) => (v as num).toInt()),
        finished: $checkedConvert('finished', (v) => (v as num).toInt()),
        avgTurns: $checkedConvert('avgTurns', (v) => v as num),
        hiroMin: $checkedConvert('hiroMin', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$AnalyticsReposInnerToJson(
  AnalyticsReposInner instance,
) => <String, dynamic>{
  'repoId': instance.repoId,
  'name': instance.name,
  'kind': instance.kind,
  'claudeMd': instance.claudeMd,
  'tickets': instance.tickets,
  'done': instance.done,
  'finished': instance.finished,
  'avgTurns': instance.avgTurns,
  'hiroMin': instance.hiroMin,
};
