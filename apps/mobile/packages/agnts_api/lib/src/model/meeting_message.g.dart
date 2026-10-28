// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_message.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingMessageCWProxy {
  MeetingMessage id(int id);

  MeetingMessage person(String person);

  MeetingMessage name(String name);

  MeetingMessage body(String body);

  MeetingMessage at(DateTime at);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingMessage call({
    int id,
    String person,
    String name,
    String body,
    DateTime at,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingMessage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingMessage.copyWith.fieldName(...)`
class _$MeetingMessageCWProxyImpl implements _$MeetingMessageCWProxy {
  const _$MeetingMessageCWProxyImpl(this._value);

  final MeetingMessage _value;

  @override
  MeetingMessage id(int id) => this(id: id);

  @override
  MeetingMessage person(String person) => this(person: person);

  @override
  MeetingMessage name(String name) => this(name: name);

  @override
  MeetingMessage body(String body) => this(body: body);

  @override
  MeetingMessage at(DateTime at) => this(at: at);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingMessage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? person = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? at = const $CopyWithPlaceholder(),
  }) {
    return MeetingMessage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      person: person == const $CopyWithPlaceholder()
          ? _value.person
          // ignore: cast_nullable_to_non_nullable
          : person as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime,
    );
  }
}

extension $MeetingMessageCopyWith on MeetingMessage {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingMessage.copyWith(...)` or like so:`instanceOfMeetingMessage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingMessageCWProxy get copyWith => _$MeetingMessageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingMessage _$MeetingMessageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingMessage', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'person', 'name', 'body', 'at'],
      );
      final val = MeetingMessage(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        person: $checkedConvert('person', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        body: $checkedConvert('body', (v) => v as String),
        at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
      );
      return val;
    });

Map<String, dynamic> _$MeetingMessageToJson(MeetingMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'person': instance.person,
      'name': instance.name,
      'body': instance.body,
      'at': instance.at.toIso8601String(),
    };
