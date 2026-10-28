// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_action_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingActionItemCWProxy {
  MeetingActionItem id(int id);

  MeetingActionItem position(int position);

  MeetingActionItem text(String text);

  MeetingActionItem who(String who);

  MeetingActionItem due(String due);

  MeetingActionItem atMs(int? atMs);

  MeetingActionItem quote(String quote);

  MeetingActionItem ticketKey(String? ticketKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingActionItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingActionItem(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingActionItem call({
    int id,
    int position,
    String text,
    String who,
    String due,
    int? atMs,
    String quote,
    String? ticketKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingActionItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingActionItem.copyWith.fieldName(...)`
class _$MeetingActionItemCWProxyImpl implements _$MeetingActionItemCWProxy {
  const _$MeetingActionItemCWProxyImpl(this._value);

  final MeetingActionItem _value;

  @override
  MeetingActionItem id(int id) => this(id: id);

  @override
  MeetingActionItem position(int position) => this(position: position);

  @override
  MeetingActionItem text(String text) => this(text: text);

  @override
  MeetingActionItem who(String who) => this(who: who);

  @override
  MeetingActionItem due(String due) => this(due: due);

  @override
  MeetingActionItem atMs(int? atMs) => this(atMs: atMs);

  @override
  MeetingActionItem quote(String quote) => this(quote: quote);

  @override
  MeetingActionItem ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingActionItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingActionItem(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingActionItem call({
    Object? id = const $CopyWithPlaceholder(),
    Object? position = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
    Object? who = const $CopyWithPlaceholder(),
    Object? due = const $CopyWithPlaceholder(),
    Object? atMs = const $CopyWithPlaceholder(),
    Object? quote = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
  }) {
    return MeetingActionItem(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      position: position == const $CopyWithPlaceholder()
          ? _value.position
          // ignore: cast_nullable_to_non_nullable
          : position as int,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
      who: who == const $CopyWithPlaceholder()
          ? _value.who
          // ignore: cast_nullable_to_non_nullable
          : who as String,
      due: due == const $CopyWithPlaceholder()
          ? _value.due
          // ignore: cast_nullable_to_non_nullable
          : due as String,
      atMs: atMs == const $CopyWithPlaceholder()
          ? _value.atMs
          // ignore: cast_nullable_to_non_nullable
          : atMs as int?,
      quote: quote == const $CopyWithPlaceholder()
          ? _value.quote
          // ignore: cast_nullable_to_non_nullable
          : quote as String,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
    );
  }
}

extension $MeetingActionItemCopyWith on MeetingActionItem {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingActionItem.copyWith(...)` or like so:`instanceOfMeetingActionItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingActionItemCWProxy get copyWith =>
      _$MeetingActionItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingActionItem _$MeetingActionItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingActionItem', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'position', 'text', 'who', 'due', 'quote'],
      );
      final val = MeetingActionItem(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        position: $checkedConvert('position', (v) => (v as num).toInt()),
        text: $checkedConvert('text', (v) => v as String),
        who: $checkedConvert('who', (v) => v as String),
        due: $checkedConvert('due', (v) => v as String),
        atMs: $checkedConvert('atMs', (v) => (v as num?)?.toInt()),
        quote: $checkedConvert('quote', (v) => v as String),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$MeetingActionItemToJson(MeetingActionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'position': instance.position,
      'text': instance.text,
      'who': instance.who,
      'due': instance.due,
      'atMs': ?instance.atMs,
      'quote': instance.quote,
      'ticketKey': ?instance.ticketKey,
    };
