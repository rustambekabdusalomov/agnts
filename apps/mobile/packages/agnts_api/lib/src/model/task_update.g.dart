// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_update.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TaskUpdateCWProxy {
  TaskUpdate title(String? title);

  TaskUpdate ticketNumber(String? ticketNumber);

  TaskUpdate description(String? description);

  TaskUpdate priority(TaskUpdatePriorityEnum? priority);

  TaskUpdate afterApprove(TaskUpdateAfterApproveEnum? afterApprove);

  TaskUpdate kind(TicketKindChoice? kind);

  TaskUpdate attachments(List<int>? attachments);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TaskUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TaskUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  TaskUpdate call({
    String? title,
    String? ticketNumber,
    String? description,
    TaskUpdatePriorityEnum? priority,
    TaskUpdateAfterApproveEnum? afterApprove,
    TicketKindChoice? kind,
    List<int>? attachments,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTaskUpdate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTaskUpdate.copyWith.fieldName(...)`
class _$TaskUpdateCWProxyImpl implements _$TaskUpdateCWProxy {
  const _$TaskUpdateCWProxyImpl(this._value);

  final TaskUpdate _value;

  @override
  TaskUpdate title(String? title) => this(title: title);

  @override
  TaskUpdate ticketNumber(String? ticketNumber) =>
      this(ticketNumber: ticketNumber);

  @override
  TaskUpdate description(String? description) => this(description: description);

  @override
  TaskUpdate priority(TaskUpdatePriorityEnum? priority) =>
      this(priority: priority);

  @override
  TaskUpdate afterApprove(TaskUpdateAfterApproveEnum? afterApprove) =>
      this(afterApprove: afterApprove);

  @override
  TaskUpdate kind(TicketKindChoice? kind) => this(kind: kind);

  @override
  TaskUpdate attachments(List<int>? attachments) =>
      this(attachments: attachments);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TaskUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TaskUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  TaskUpdate call({
    Object? title = const $CopyWithPlaceholder(),
    Object? ticketNumber = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? priority = const $CopyWithPlaceholder(),
    Object? afterApprove = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
  }) {
    return TaskUpdate(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      ticketNumber: ticketNumber == const $CopyWithPlaceholder()
          ? _value.ticketNumber
          // ignore: cast_nullable_to_non_nullable
          : ticketNumber as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      priority: priority == const $CopyWithPlaceholder()
          ? _value.priority
          // ignore: cast_nullable_to_non_nullable
          : priority as TaskUpdatePriorityEnum?,
      afterApprove: afterApprove == const $CopyWithPlaceholder()
          ? _value.afterApprove
          // ignore: cast_nullable_to_non_nullable
          : afterApprove as TaskUpdateAfterApproveEnum?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as TicketKindChoice?,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<int>?,
    );
  }
}

extension $TaskUpdateCopyWith on TaskUpdate {
  /// Returns a callable class that can be used as follows: `instanceOfTaskUpdate.copyWith(...)` or like so:`instanceOfTaskUpdate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TaskUpdateCWProxy get copyWith => _$TaskUpdateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskUpdate _$TaskUpdateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TaskUpdate', json, ($checkedConvert) {
      final val = TaskUpdate(
        title: $checkedConvert('title', (v) => v as String?),
        ticketNumber: $checkedConvert('ticketNumber', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
        priority: $checkedConvert(
          'priority',
          (v) => $enumDecodeNullable(_$TaskUpdatePriorityEnumEnumMap, v),
        ),
        afterApprove: $checkedConvert(
          'afterApprove',
          (v) => $enumDecodeNullable(_$TaskUpdateAfterApproveEnumEnumMap, v),
        ),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecodeNullable(_$TicketKindChoiceEnumMap, v),
        ),
        attachments: $checkedConvert(
          'attachments',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TaskUpdateToJson(
  TaskUpdate instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'ticketNumber': ?instance.ticketNumber,
  'description': ?instance.description,
  'priority': ?_$TaskUpdatePriorityEnumEnumMap[instance.priority],
  'afterApprove': ?_$TaskUpdateAfterApproveEnumEnumMap[instance.afterApprove],
  'kind': ?_$TicketKindChoiceEnumMap[instance.kind],
  'attachments': ?instance.attachments,
};

const _$TaskUpdatePriorityEnumEnumMap = {
  TaskUpdatePriorityEnum.low: 'low',
  TaskUpdatePriorityEnum.medium: 'medium',
  TaskUpdatePriorityEnum.high: 'high',
};

const _$TaskUpdateAfterApproveEnumEnumMap = {
  TaskUpdateAfterApproveEnum.pr: 'pr',
  TaskUpdateAfterApproveEnum.main: 'main',
};

const _$TicketKindChoiceEnumMap = {
  TicketKindChoice.auto: 'auto',
  TicketKindChoice.code: 'code',
  TicketKindChoice.test: 'test',
  TicketKindChoice.plan: 'plan',
  TicketKindChoice.analysis: 'analysis',
  TicketKindChoice.bug: 'bug',
};
