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

  MeetingActionItem speaker(String speaker);

  MeetingActionItem memberId(int? memberId);

  MeetingActionItem memberName(String? memberName);

  MeetingActionItem memberByHand(bool memberByHand);

  MeetingActionItem drafted(bool drafted);

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
    String speaker,
    int? memberId,
    String? memberName,
    bool memberByHand,
    bool drafted,
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
  MeetingActionItem speaker(String speaker) => this(speaker: speaker);

  @override
  MeetingActionItem memberId(int? memberId) => this(memberId: memberId);

  @override
  MeetingActionItem memberName(String? memberName) =>
      this(memberName: memberName);

  @override
  MeetingActionItem memberByHand(bool memberByHand) =>
      this(memberByHand: memberByHand);

  @override
  MeetingActionItem drafted(bool drafted) => this(drafted: drafted);

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
    Object? speaker = const $CopyWithPlaceholder(),
    Object? memberId = const $CopyWithPlaceholder(),
    Object? memberName = const $CopyWithPlaceholder(),
    Object? memberByHand = const $CopyWithPlaceholder(),
    Object? drafted = const $CopyWithPlaceholder(),
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
      speaker: speaker == const $CopyWithPlaceholder()
          ? _value.speaker
          // ignore: cast_nullable_to_non_nullable
          : speaker as String,
      memberId: memberId == const $CopyWithPlaceholder()
          ? _value.memberId
          // ignore: cast_nullable_to_non_nullable
          : memberId as int?,
      memberName: memberName == const $CopyWithPlaceholder()
          ? _value.memberName
          // ignore: cast_nullable_to_non_nullable
          : memberName as String?,
      memberByHand: memberByHand == const $CopyWithPlaceholder()
          ? _value.memberByHand
          // ignore: cast_nullable_to_non_nullable
          : memberByHand as bool,
      drafted: drafted == const $CopyWithPlaceholder()
          ? _value.drafted
          // ignore: cast_nullable_to_non_nullable
          : drafted as bool,
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
        requiredKeys: const [
          'id',
          'position',
          'text',
          'who',
          'due',
          'quote',
          'speaker',
          'memberByHand',
          'drafted',
        ],
      );
      final val = MeetingActionItem(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        position: $checkedConvert('position', (v) => (v as num).toInt()),
        text: $checkedConvert('text', (v) => v as String),
        who: $checkedConvert('who', (v) => v as String),
        due: $checkedConvert('due', (v) => v as String),
        atMs: $checkedConvert('atMs', (v) => (v as num?)?.toInt()),
        quote: $checkedConvert('quote', (v) => v as String),
        speaker: $checkedConvert('speaker', (v) => v as String),
        memberId: $checkedConvert('memberId', (v) => (v as num?)?.toInt()),
        memberName: $checkedConvert('memberName', (v) => v as String?),
        memberByHand: $checkedConvert('memberByHand', (v) => v as bool),
        drafted: $checkedConvert('drafted', (v) => v as bool),
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
      'speaker': instance.speaker,
      'memberId': ?instance.memberId,
      'memberName': ?instance.memberName,
      'memberByHand': instance.memberByHand,
      'drafted': instance.drafted,
      'ticketKey': ?instance.ticketKey,
    };
