// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_session.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GuestSessionCWProxy {
  GuestSession token(String token);

  GuestSession name(String name);

  GuestSession via(GuestSessionViaEnum via);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GuestSession(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GuestSession(...).copyWith(id: 12, name: "My name")
  /// ````
  GuestSession call({String token, String name, GuestSessionViaEnum via});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGuestSession.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGuestSession.copyWith.fieldName(...)`
class _$GuestSessionCWProxyImpl implements _$GuestSessionCWProxy {
  const _$GuestSessionCWProxyImpl(this._value);

  final GuestSession _value;

  @override
  GuestSession token(String token) => this(token: token);

  @override
  GuestSession name(String name) => this(name: name);

  @override
  GuestSession via(GuestSessionViaEnum via) => this(via: via);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GuestSession(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GuestSession(...).copyWith(id: 12, name: "My name")
  /// ````
  GuestSession call({
    Object? token = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? via = const $CopyWithPlaceholder(),
  }) {
    return GuestSession(
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      via: via == const $CopyWithPlaceholder()
          ? _value.via
          // ignore: cast_nullable_to_non_nullable
          : via as GuestSessionViaEnum,
    );
  }
}

extension $GuestSessionCopyWith on GuestSession {
  /// Returns a callable class that can be used as follows: `instanceOfGuestSession.copyWith(...)` or like so:`instanceOfGuestSession.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GuestSessionCWProxy get copyWith => _$GuestSessionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuestSession _$GuestSessionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GuestSession', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['token', 'name', 'via']);
      final val = GuestSession(
        token: $checkedConvert('token', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        via: $checkedConvert(
          'via',
          (v) => $enumDecode(_$GuestSessionViaEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GuestSessionToJson(GuestSession instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'via': _$GuestSessionViaEnumEnumMap[instance.via]!,
    };

const _$GuestSessionViaEnumEnumMap = {
  GuestSessionViaEnum.name: 'name',
  GuestSessionViaEnum.google: 'google',
  GuestSessionViaEnum.account: 'account',
};
