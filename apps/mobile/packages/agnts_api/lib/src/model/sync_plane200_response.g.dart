// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_plane200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SyncPlane200ResponseCWProxy {
  SyncPlane200Response found(int found);

  SyncPlane200Response created(int created);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SyncPlane200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SyncPlane200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  SyncPlane200Response call({int found, int created});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSyncPlane200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSyncPlane200Response.copyWith.fieldName(...)`
class _$SyncPlane200ResponseCWProxyImpl
    implements _$SyncPlane200ResponseCWProxy {
  const _$SyncPlane200ResponseCWProxyImpl(this._value);

  final SyncPlane200Response _value;

  @override
  SyncPlane200Response found(int found) => this(found: found);

  @override
  SyncPlane200Response created(int created) => this(created: created);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SyncPlane200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SyncPlane200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  SyncPlane200Response call({
    Object? found = const $CopyWithPlaceholder(),
    Object? created = const $CopyWithPlaceholder(),
  }) {
    return SyncPlane200Response(
      found: found == const $CopyWithPlaceholder()
          ? _value.found
          // ignore: cast_nullable_to_non_nullable
          : found as int,
      created: created == const $CopyWithPlaceholder()
          ? _value.created
          // ignore: cast_nullable_to_non_nullable
          : created as int,
    );
  }
}

extension $SyncPlane200ResponseCopyWith on SyncPlane200Response {
  /// Returns a callable class that can be used as follows: `instanceOfSyncPlane200Response.copyWith(...)` or like so:`instanceOfSyncPlane200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SyncPlane200ResponseCWProxy get copyWith =>
      _$SyncPlane200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncPlane200Response _$SyncPlane200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SyncPlane200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['found', 'created']);
  final val = SyncPlane200Response(
    found: $checkedConvert('found', (v) => (v as num).toInt()),
    created: $checkedConvert('created', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$SyncPlane200ResponseToJson(
  SyncPlane200Response instance,
) => <String, dynamic>{'found': instance.found, 'created': instance.created};
