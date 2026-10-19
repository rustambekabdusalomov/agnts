// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_review_ref.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullReviewRefCWProxy {
  PullReviewRef key(String key);

  PullReviewRef state(TicketState state);

  PullReviewRef headSha(String? headSha);

  PullReviewRef createdAt(DateTime createdAt);

  PullReviewRef updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullReviewRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullReviewRef(...).copyWith(id: 12, name: "My name")
  /// ````
  PullReviewRef call({
    String key,
    TicketState state,
    String? headSha,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullReviewRef.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullReviewRef.copyWith.fieldName(...)`
class _$PullReviewRefCWProxyImpl implements _$PullReviewRefCWProxy {
  const _$PullReviewRefCWProxyImpl(this._value);

  final PullReviewRef _value;

  @override
  PullReviewRef key(String key) => this(key: key);

  @override
  PullReviewRef state(TicketState state) => this(state: state);

  @override
  PullReviewRef headSha(String? headSha) => this(headSha: headSha);

  @override
  PullReviewRef createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  PullReviewRef updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullReviewRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullReviewRef(...).copyWith(id: 12, name: "My name")
  /// ````
  PullReviewRef call({
    Object? key = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? headSha = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return PullReviewRef(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as TicketState,
      headSha: headSha == const $CopyWithPlaceholder()
          ? _value.headSha
          // ignore: cast_nullable_to_non_nullable
          : headSha as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $PullReviewRefCopyWith on PullReviewRef {
  /// Returns a callable class that can be used as follows: `instanceOfPullReviewRef.copyWith(...)` or like so:`instanceOfPullReviewRef.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullReviewRefCWProxy get copyWith => _$PullReviewRefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullReviewRef _$PullReviewRefFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PullReviewRef', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['key', 'state', 'createdAt', 'updatedAt'],
  );
  final val = PullReviewRef(
    key: $checkedConvert('key', (v) => v as String),
    state: $checkedConvert(
      'state',
      (v) => $enumDecode(_$TicketStateEnumMap, v),
    ),
    headSha: $checkedConvert('headSha', (v) => v as String?),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$PullReviewRefToJson(PullReviewRef instance) =>
    <String, dynamic>{
      'key': instance.key,
      'state': _$TicketStateEnumMap[instance.state]!,
      'headSha': ?instance.headSha,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TicketStateEnumMap = {
  TicketState.new_: 'new',
  TicketState.analyzing: 'analyzing',
  TicketState.waitingForAnswers: 'waiting_for_answers',
  TicketState.coding: 'coding',
  TicketState.testing: 'testing',
  TicketState.waitingForReview: 'waiting_for_review',
  TicketState.pushing: 'pushing',
  TicketState.done: 'done',
  TicketState.rejected: 'rejected',
  TicketState.failed: 'failed',
  TicketState.rateLimited: 'rate_limited',
};
