// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_invitees_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingInviteesInputCWProxy {
  MeetingInviteesInput add(MeetingInvites? add);

  MeetingInviteesInput remove(List<int>? remove);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingInviteesInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingInviteesInput(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingInviteesInput call({MeetingInvites? add, List<int>? remove});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingInviteesInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingInviteesInput.copyWith.fieldName(...)`
class _$MeetingInviteesInputCWProxyImpl
    implements _$MeetingInviteesInputCWProxy {
  const _$MeetingInviteesInputCWProxyImpl(this._value);

  final MeetingInviteesInput _value;

  @override
  MeetingInviteesInput add(MeetingInvites? add) => this(add: add);

  @override
  MeetingInviteesInput remove(List<int>? remove) => this(remove: remove);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingInviteesInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingInviteesInput(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingInviteesInput call({
    Object? add = const $CopyWithPlaceholder(),
    Object? remove = const $CopyWithPlaceholder(),
  }) {
    return MeetingInviteesInput(
      add: add == const $CopyWithPlaceholder()
          ? _value.add
          // ignore: cast_nullable_to_non_nullable
          : add as MeetingInvites?,
      remove: remove == const $CopyWithPlaceholder()
          ? _value.remove
          // ignore: cast_nullable_to_non_nullable
          : remove as List<int>?,
    );
  }
}

extension $MeetingInviteesInputCopyWith on MeetingInviteesInput {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingInviteesInput.copyWith(...)` or like so:`instanceOfMeetingInviteesInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingInviteesInputCWProxy get copyWith =>
      _$MeetingInviteesInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingInviteesInput _$MeetingInviteesInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MeetingInviteesInput', json, ($checkedConvert) {
  final val = MeetingInviteesInput(
    add: $checkedConvert(
      'add',
      (v) =>
          v == null ? null : MeetingInvites.fromJson(v as Map<String, dynamic>),
    ),
    remove: $checkedConvert(
      'remove',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$MeetingInviteesInputToJson(
  MeetingInviteesInput instance,
) => <String, dynamic>{
  'add': ?instance.add?.toJson(),
  'remove': ?instance.remove,
};
