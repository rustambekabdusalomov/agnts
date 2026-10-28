// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_timeline.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CodeTimelineCWProxy {
  CodeTimeline conversation(AssistantConversation conversation);

  CodeTimeline items(List<TimelineItem> items);

  CodeTimeline approvals(List<CodeApproval> approvals);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeTimeline(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeTimeline(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeTimeline call({
    AssistantConversation conversation,
    List<TimelineItem> items,
    List<CodeApproval> approvals,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCodeTimeline.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCodeTimeline.copyWith.fieldName(...)`
class _$CodeTimelineCWProxyImpl implements _$CodeTimelineCWProxy {
  const _$CodeTimelineCWProxyImpl(this._value);

  final CodeTimeline _value;

  @override
  CodeTimeline conversation(AssistantConversation conversation) =>
      this(conversation: conversation);

  @override
  CodeTimeline items(List<TimelineItem> items) => this(items: items);

  @override
  CodeTimeline approvals(List<CodeApproval> approvals) =>
      this(approvals: approvals);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeTimeline(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeTimeline(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeTimeline call({
    Object? conversation = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
    Object? approvals = const $CopyWithPlaceholder(),
  }) {
    return CodeTimeline(
      conversation: conversation == const $CopyWithPlaceholder()
          ? _value.conversation
          // ignore: cast_nullable_to_non_nullable
          : conversation as AssistantConversation,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<TimelineItem>,
      approvals: approvals == const $CopyWithPlaceholder()
          ? _value.approvals
          // ignore: cast_nullable_to_non_nullable
          : approvals as List<CodeApproval>,
    );
  }
}

extension $CodeTimelineCopyWith on CodeTimeline {
  /// Returns a callable class that can be used as follows: `instanceOfCodeTimeline.copyWith(...)` or like so:`instanceOfCodeTimeline.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CodeTimelineCWProxy get copyWith => _$CodeTimelineCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeTimeline _$CodeTimelineFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CodeTimeline', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['conversation', 'items', 'approvals'],
      );
      final val = CodeTimeline(
        conversation: $checkedConvert(
          'conversation',
          (v) => AssistantConversation.fromJson(v as Map<String, dynamic>),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => TimelineItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        approvals: $checkedConvert(
          'approvals',
          (v) => (v as List<dynamic>)
              .map((e) => CodeApproval.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CodeTimelineToJson(CodeTimeline instance) =>
    <String, dynamic>{
      'conversation': instance.conversation.toJson(),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'approvals': instance.approvals.map((e) => e.toJson()).toList(),
    };
