// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_stats_actions.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantStatsActionsCWProxy {
  AssistantStatsActions proposed(int proposed);

  AssistantStatsActions done(int done);

  AssistantStatsActions failed(int failed);

  AssistantStatsActions cancelled(int cancelled);

  AssistantStatsActions expired(int expired);

  AssistantStatsActions notOffered(int notOffered);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantStatsActions(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantStatsActions(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantStatsActions call({
    int proposed,
    int done,
    int failed,
    int cancelled,
    int expired,
    int notOffered,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantStatsActions.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantStatsActions.copyWith.fieldName(...)`
class _$AssistantStatsActionsCWProxyImpl
    implements _$AssistantStatsActionsCWProxy {
  const _$AssistantStatsActionsCWProxyImpl(this._value);

  final AssistantStatsActions _value;

  @override
  AssistantStatsActions proposed(int proposed) => this(proposed: proposed);

  @override
  AssistantStatsActions done(int done) => this(done: done);

  @override
  AssistantStatsActions failed(int failed) => this(failed: failed);

  @override
  AssistantStatsActions cancelled(int cancelled) => this(cancelled: cancelled);

  @override
  AssistantStatsActions expired(int expired) => this(expired: expired);

  @override
  AssistantStatsActions notOffered(int notOffered) =>
      this(notOffered: notOffered);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantStatsActions(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantStatsActions(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantStatsActions call({
    Object? proposed = const $CopyWithPlaceholder(),
    Object? done = const $CopyWithPlaceholder(),
    Object? failed = const $CopyWithPlaceholder(),
    Object? cancelled = const $CopyWithPlaceholder(),
    Object? expired = const $CopyWithPlaceholder(),
    Object? notOffered = const $CopyWithPlaceholder(),
  }) {
    return AssistantStatsActions(
      proposed: proposed == const $CopyWithPlaceholder()
          ? _value.proposed
          // ignore: cast_nullable_to_non_nullable
          : proposed as int,
      done: done == const $CopyWithPlaceholder()
          ? _value.done
          // ignore: cast_nullable_to_non_nullable
          : done as int,
      failed: failed == const $CopyWithPlaceholder()
          ? _value.failed
          // ignore: cast_nullable_to_non_nullable
          : failed as int,
      cancelled: cancelled == const $CopyWithPlaceholder()
          ? _value.cancelled
          // ignore: cast_nullable_to_non_nullable
          : cancelled as int,
      expired: expired == const $CopyWithPlaceholder()
          ? _value.expired
          // ignore: cast_nullable_to_non_nullable
          : expired as int,
      notOffered: notOffered == const $CopyWithPlaceholder()
          ? _value.notOffered
          // ignore: cast_nullable_to_non_nullable
          : notOffered as int,
    );
  }
}

extension $AssistantStatsActionsCopyWith on AssistantStatsActions {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantStatsActions.copyWith(...)` or like so:`instanceOfAssistantStatsActions.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantStatsActionsCWProxy get copyWith =>
      _$AssistantStatsActionsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantStatsActions _$AssistantStatsActionsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantStatsActions', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'proposed',
      'done',
      'failed',
      'cancelled',
      'expired',
      'notOffered',
    ],
  );
  final val = AssistantStatsActions(
    proposed: $checkedConvert('proposed', (v) => (v as num).toInt()),
    done: $checkedConvert('done', (v) => (v as num).toInt()),
    failed: $checkedConvert('failed', (v) => (v as num).toInt()),
    cancelled: $checkedConvert('cancelled', (v) => (v as num).toInt()),
    expired: $checkedConvert('expired', (v) => (v as num).toInt()),
    notOffered: $checkedConvert('notOffered', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$AssistantStatsActionsToJson(
  AssistantStatsActions instance,
) => <String, dynamic>{
  'proposed': instance.proposed,
  'done': instance.done,
  'failed': instance.failed,
  'cancelled': instance.cancelled,
  'expired': instance.expired,
  'notOffered': instance.notOffered,
};
