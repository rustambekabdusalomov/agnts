// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TaskCreateCWProxy {
  TaskCreate repoId(int? repoId);

  TaskCreate kind(TicketKindChoice? kind);

  TaskCreate title(String title);

  TaskCreate description(String? description);

  TaskCreate priority(TaskCreatePriorityEnum priority);

  TaskCreate afterApprove(TaskCreateAfterApproveEnum afterApprove);

  TaskCreate start(TaskCreateStartEnum start);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TaskCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TaskCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  TaskCreate call({
    int? repoId,
    TicketKindChoice? kind,
    String title,
    String? description,
    TaskCreatePriorityEnum priority,
    TaskCreateAfterApproveEnum afterApprove,
    TaskCreateStartEnum start,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTaskCreate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTaskCreate.copyWith.fieldName(...)`
class _$TaskCreateCWProxyImpl implements _$TaskCreateCWProxy {
  const _$TaskCreateCWProxyImpl(this._value);

  final TaskCreate _value;

  @override
  TaskCreate repoId(int? repoId) => this(repoId: repoId);

  @override
  TaskCreate kind(TicketKindChoice? kind) => this(kind: kind);

  @override
  TaskCreate title(String title) => this(title: title);

  @override
  TaskCreate description(String? description) => this(description: description);

  @override
  TaskCreate priority(TaskCreatePriorityEnum priority) =>
      this(priority: priority);

  @override
  TaskCreate afterApprove(TaskCreateAfterApproveEnum afterApprove) =>
      this(afterApprove: afterApprove);

  @override
  TaskCreate start(TaskCreateStartEnum start) => this(start: start);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TaskCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TaskCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  TaskCreate call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? priority = const $CopyWithPlaceholder(),
    Object? afterApprove = const $CopyWithPlaceholder(),
    Object? start = const $CopyWithPlaceholder(),
  }) {
    return TaskCreate(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as TicketKindChoice?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      priority: priority == const $CopyWithPlaceholder()
          ? _value.priority
          // ignore: cast_nullable_to_non_nullable
          : priority as TaskCreatePriorityEnum,
      afterApprove: afterApprove == const $CopyWithPlaceholder()
          ? _value.afterApprove
          // ignore: cast_nullable_to_non_nullable
          : afterApprove as TaskCreateAfterApproveEnum,
      start: start == const $CopyWithPlaceholder()
          ? _value.start
          // ignore: cast_nullable_to_non_nullable
          : start as TaskCreateStartEnum,
    );
  }
}

extension $TaskCreateCopyWith on TaskCreate {
  /// Returns a callable class that can be used as follows: `instanceOfTaskCreate.copyWith(...)` or like so:`instanceOfTaskCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TaskCreateCWProxy get copyWith => _$TaskCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCreate _$TaskCreateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TaskCreate', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['title', 'priority', 'afterApprove', 'start'],
      );
      final val = TaskCreate(
        repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecodeNullable(_$TicketKindChoiceEnumMap, v),
        ),
        title: $checkedConvert('title', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String?),
        priority: $checkedConvert(
          'priority',
          (v) => $enumDecode(_$TaskCreatePriorityEnumEnumMap, v),
        ),
        afterApprove: $checkedConvert(
          'afterApprove',
          (v) => $enumDecode(_$TaskCreateAfterApproveEnumEnumMap, v),
        ),
        start: $checkedConvert(
          'start',
          (v) => $enumDecode(_$TaskCreateStartEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TaskCreateToJson(
  TaskCreate instance,
) => <String, dynamic>{
  'repoId': ?instance.repoId,
  'kind': ?_$TicketKindChoiceEnumMap[instance.kind],
  'title': instance.title,
  'description': ?instance.description,
  'priority': _$TaskCreatePriorityEnumEnumMap[instance.priority]!,
  'afterApprove': _$TaskCreateAfterApproveEnumEnumMap[instance.afterApprove]!,
  'start': _$TaskCreateStartEnumEnumMap[instance.start]!,
};

const _$TicketKindChoiceEnumMap = {
  TicketKindChoice.auto: 'auto',
  TicketKindChoice.code: 'code',
  TicketKindChoice.test: 'test',
  TicketKindChoice.plan: 'plan',
  TicketKindChoice.analysis: 'analysis',
  TicketKindChoice.bug: 'bug',
};

const _$TaskCreatePriorityEnumEnumMap = {
  TaskCreatePriorityEnum.low: 'low',
  TaskCreatePriorityEnum.medium: 'medium',
  TaskCreatePriorityEnum.high: 'high',
};

const _$TaskCreateAfterApproveEnumEnumMap = {
  TaskCreateAfterApproveEnum.pr: 'pr',
  TaskCreateAfterApproveEnum.main: 'main',
};

const _$TaskCreateStartEnumEnumMap = {
  TaskCreateStartEnum.ask: 'ask',
  TaskCreateStartEnum.code: 'code',
  TaskCreateStartEnum.queue: 'queue',
};
