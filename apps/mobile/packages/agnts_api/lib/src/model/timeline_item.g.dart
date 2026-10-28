// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TimelineItemCWProxy {
  TimelineItem at(DateTime at);

  TimelineItem message(AssistantMessage? message);

  TimelineItem event(Event? event);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TimelineItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TimelineItem(...).copyWith(id: 12, name: "My name")
  /// ````
  TimelineItem call({DateTime at, AssistantMessage? message, Event? event});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimelineItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTimelineItem.copyWith.fieldName(...)`
class _$TimelineItemCWProxyImpl implements _$TimelineItemCWProxy {
  const _$TimelineItemCWProxyImpl(this._value);

  final TimelineItem _value;

  @override
  TimelineItem at(DateTime at) => this(at: at);

  @override
  TimelineItem message(AssistantMessage? message) => this(message: message);

  @override
  TimelineItem event(Event? event) => this(event: event);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TimelineItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TimelineItem(...).copyWith(id: 12, name: "My name")
  /// ````
  TimelineItem call({
    Object? at = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? event = const $CopyWithPlaceholder(),
  }) {
    return TimelineItem(
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as AssistantMessage?,
      event: event == const $CopyWithPlaceholder()
          ? _value.event
          // ignore: cast_nullable_to_non_nullable
          : event as Event?,
    );
  }
}

extension $TimelineItemCopyWith on TimelineItem {
  /// Returns a callable class that can be used as follows: `instanceOfTimelineItem.copyWith(...)` or like so:`instanceOfTimelineItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TimelineItemCWProxy get copyWith => _$TimelineItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineItem _$TimelineItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TimelineItem', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['at']);
      final val = TimelineItem(
        at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
        message: $checkedConvert(
          'message',
          (v) => v == null
              ? null
              : AssistantMessage.fromJson(v as Map<String, dynamic>),
        ),
        event: $checkedConvert(
          'event',
          (v) => v == null ? null : Event.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TimelineItemToJson(TimelineItem instance) =>
    <String, dynamic>{
      'at': instance.at.toIso8601String(),
      'message': ?instance.message?.toJson(),
      'event': ?instance.event?.toJson(),
    };
