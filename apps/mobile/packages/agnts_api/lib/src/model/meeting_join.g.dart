// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_join.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingJoinCWProxy {
  MeetingJoin status(MeetingJoinStatusEnum status);

  MeetingJoin grant(MeetingGrant? grant);

  MeetingJoin knockId(int? knockId);

  MeetingJoin knockToken(String? knockToken);

  MeetingJoin guestToken(String? guestToken);

  MeetingJoin guestName(String? guestName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingJoin(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingJoin(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingJoin call({
    MeetingJoinStatusEnum status,
    MeetingGrant? grant,
    int? knockId,
    String? knockToken,
    String? guestToken,
    String? guestName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingJoin.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingJoin.copyWith.fieldName(...)`
class _$MeetingJoinCWProxyImpl implements _$MeetingJoinCWProxy {
  const _$MeetingJoinCWProxyImpl(this._value);

  final MeetingJoin _value;

  @override
  MeetingJoin status(MeetingJoinStatusEnum status) => this(status: status);

  @override
  MeetingJoin grant(MeetingGrant? grant) => this(grant: grant);

  @override
  MeetingJoin knockId(int? knockId) => this(knockId: knockId);

  @override
  MeetingJoin knockToken(String? knockToken) => this(knockToken: knockToken);

  @override
  MeetingJoin guestToken(String? guestToken) => this(guestToken: guestToken);

  @override
  MeetingJoin guestName(String? guestName) => this(guestName: guestName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingJoin(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingJoin(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingJoin call({
    Object? status = const $CopyWithPlaceholder(),
    Object? grant = const $CopyWithPlaceholder(),
    Object? knockId = const $CopyWithPlaceholder(),
    Object? knockToken = const $CopyWithPlaceholder(),
    Object? guestToken = const $CopyWithPlaceholder(),
    Object? guestName = const $CopyWithPlaceholder(),
  }) {
    return MeetingJoin(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as MeetingJoinStatusEnum,
      grant: grant == const $CopyWithPlaceholder()
          ? _value.grant
          // ignore: cast_nullable_to_non_nullable
          : grant as MeetingGrant?,
      knockId: knockId == const $CopyWithPlaceholder()
          ? _value.knockId
          // ignore: cast_nullable_to_non_nullable
          : knockId as int?,
      knockToken: knockToken == const $CopyWithPlaceholder()
          ? _value.knockToken
          // ignore: cast_nullable_to_non_nullable
          : knockToken as String?,
      guestToken: guestToken == const $CopyWithPlaceholder()
          ? _value.guestToken
          // ignore: cast_nullable_to_non_nullable
          : guestToken as String?,
      guestName: guestName == const $CopyWithPlaceholder()
          ? _value.guestName
          // ignore: cast_nullable_to_non_nullable
          : guestName as String?,
    );
  }
}

extension $MeetingJoinCopyWith on MeetingJoin {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingJoin.copyWith(...)` or like so:`instanceOfMeetingJoin.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingJoinCWProxy get copyWith => _$MeetingJoinCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingJoin _$MeetingJoinFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MeetingJoin',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['status']);
    final val = MeetingJoin(
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$MeetingJoinStatusEnumEnumMap, v),
      ),
      grant: $checkedConvert(
        'grant',
        (v) =>
            v == null ? null : MeetingGrant.fromJson(v as Map<String, dynamic>),
      ),
      knockId: $checkedConvert('knockId', (v) => (v as num?)?.toInt()),
      knockToken: $checkedConvert('knockToken', (v) => v as String?),
      guestToken: $checkedConvert('guestToken', (v) => v as String?),
      guestName: $checkedConvert('guestName', (v) => v as String?),
    );
    return val;
  },
);

Map<String, dynamic> _$MeetingJoinToJson(MeetingJoin instance) =>
    <String, dynamic>{
      'status': _$MeetingJoinStatusEnumEnumMap[instance.status]!,
      'grant': ?instance.grant?.toJson(),
      'knockId': ?instance.knockId,
      'knockToken': ?instance.knockToken,
      'guestToken': ?instance.guestToken,
      'guestName': ?instance.guestName,
    };

const _$MeetingJoinStatusEnumEnumMap = {
  MeetingJoinStatusEnum.joined: 'joined',
  MeetingJoinStatusEnum.waiting: 'waiting',
};
