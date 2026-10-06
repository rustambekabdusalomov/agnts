// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_follow_up.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AcceptFollowUpCWProxy {
  AcceptFollowUp id(int id);

  AcceptFollowUp target(AcceptFollowUpTargetEnum? target);

  AcceptFollowUp title(String? title);

  AcceptFollowUp description(String? description);

  AcceptFollowUp kind(TicketKind? kind);

  AcceptFollowUp priority(AcceptFollowUpPriorityEnum? priority);

  AcceptFollowUp repoId(int? repoId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptFollowUp(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptFollowUp(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptFollowUp call({
    int id,
    AcceptFollowUpTargetEnum? target,
    String? title,
    String? description,
    TicketKind? kind,
    AcceptFollowUpPriorityEnum? priority,
    int? repoId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAcceptFollowUp.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAcceptFollowUp.copyWith.fieldName(...)`
class _$AcceptFollowUpCWProxyImpl implements _$AcceptFollowUpCWProxy {
  const _$AcceptFollowUpCWProxyImpl(this._value);

  final AcceptFollowUp _value;

  @override
  AcceptFollowUp id(int id) => this(id: id);

  @override
  AcceptFollowUp target(AcceptFollowUpTargetEnum? target) =>
      this(target: target);

  @override
  AcceptFollowUp title(String? title) => this(title: title);

  @override
  AcceptFollowUp description(String? description) =>
      this(description: description);

  @override
  AcceptFollowUp kind(TicketKind? kind) => this(kind: kind);

  @override
  AcceptFollowUp priority(AcceptFollowUpPriorityEnum? priority) =>
      this(priority: priority);

  @override
  AcceptFollowUp repoId(int? repoId) => this(repoId: repoId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptFollowUp(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptFollowUp(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptFollowUp call({
    Object? id = const $CopyWithPlaceholder(),
    Object? target = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? priority = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
  }) {
    return AcceptFollowUp(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      target: target == const $CopyWithPlaceholder()
          ? _value.target
          // ignore: cast_nullable_to_non_nullable
          : target as AcceptFollowUpTargetEnum?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as TicketKind?,
      priority: priority == const $CopyWithPlaceholder()
          ? _value.priority
          // ignore: cast_nullable_to_non_nullable
          : priority as AcceptFollowUpPriorityEnum?,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
    );
  }
}

extension $AcceptFollowUpCopyWith on AcceptFollowUp {
  /// Returns a callable class that can be used as follows: `instanceOfAcceptFollowUp.copyWith(...)` or like so:`instanceOfAcceptFollowUp.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AcceptFollowUpCWProxy get copyWith => _$AcceptFollowUpCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptFollowUp _$AcceptFollowUpFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AcceptFollowUp', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id']);
      final val = AcceptFollowUp(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        target: $checkedConvert(
          'target',
          (v) => $enumDecodeNullable(_$AcceptFollowUpTargetEnumEnumMap, v),
        ),
        title: $checkedConvert('title', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecodeNullable(_$TicketKindEnumMap, v),
        ),
        priority: $checkedConvert(
          'priority',
          (v) => $enumDecodeNullable(_$AcceptFollowUpPriorityEnumEnumMap, v),
        ),
        repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$AcceptFollowUpToJson(AcceptFollowUp instance) =>
    <String, dynamic>{
      'id': instance.id,
      'target': ?_$AcceptFollowUpTargetEnumEnumMap[instance.target],
      'title': ?instance.title,
      'description': ?instance.description,
      'kind': ?_$TicketKindEnumMap[instance.kind],
      'priority': ?_$AcceptFollowUpPriorityEnumEnumMap[instance.priority],
      'repoId': ?instance.repoId,
    };

const _$AcceptFollowUpTargetEnumEnumMap = {
  AcceptFollowUpTargetEnum.local: 'local',
  AcceptFollowUpTargetEnum.jira: 'jira',
};

const _$TicketKindEnumMap = {
  TicketKind.code: 'code',
  TicketKind.test: 'test',
  TicketKind.plan: 'plan',
  TicketKind.analysis: 'analysis',
  TicketKind.bug: 'bug',
};

const _$AcceptFollowUpPriorityEnumEnumMap = {
  AcceptFollowUpPriorityEnum.low: 'low',
  AcceptFollowUpPriorityEnum.medium: 'medium',
  AcceptFollowUpPriorityEnum.high: 'high',
};
