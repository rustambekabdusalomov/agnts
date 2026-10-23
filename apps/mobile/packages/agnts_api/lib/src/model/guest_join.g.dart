// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_join.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GuestJoinCWProxy {
  GuestJoin name(String? name);

  GuestJoin googleCredential(String? googleCredential);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GuestJoin(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GuestJoin(...).copyWith(id: 12, name: "My name")
  /// ````
  GuestJoin call({String? name, String? googleCredential});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGuestJoin.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGuestJoin.copyWith.fieldName(...)`
class _$GuestJoinCWProxyImpl implements _$GuestJoinCWProxy {
  const _$GuestJoinCWProxyImpl(this._value);

  final GuestJoin _value;

  @override
  GuestJoin name(String? name) => this(name: name);

  @override
  GuestJoin googleCredential(String? googleCredential) =>
      this(googleCredential: googleCredential);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GuestJoin(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GuestJoin(...).copyWith(id: 12, name: "My name")
  /// ````
  GuestJoin call({
    Object? name = const $CopyWithPlaceholder(),
    Object? googleCredential = const $CopyWithPlaceholder(),
  }) {
    return GuestJoin(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      googleCredential: googleCredential == const $CopyWithPlaceholder()
          ? _value.googleCredential
          // ignore: cast_nullable_to_non_nullable
          : googleCredential as String?,
    );
  }
}

extension $GuestJoinCopyWith on GuestJoin {
  /// Returns a callable class that can be used as follows: `instanceOfGuestJoin.copyWith(...)` or like so:`instanceOfGuestJoin.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GuestJoinCWProxy get copyWith => _$GuestJoinCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuestJoin _$GuestJoinFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GuestJoin', json, ($checkedConvert) {
      final val = GuestJoin(
        name: $checkedConvert('name', (v) => v as String?),
        googleCredential: $checkedConvert(
          'googleCredential',
          (v) => v as String?,
        ),
      );
      return val;
    });

Map<String, dynamic> _$GuestJoinToJson(GuestJoin instance) => <String, dynamic>{
  'name': ?instance.name,
  'googleCredential': ?instance.googleCredential,
};
