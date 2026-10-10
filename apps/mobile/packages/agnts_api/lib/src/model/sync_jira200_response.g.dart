// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_jira200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SyncJira200ResponseCWProxy {
  SyncJira200Response found(int found);

  SyncJira200Response created(int created);

  SyncJira200Response updated(int? updated);

  SyncJira200Response waiting(int? waiting);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SyncJira200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SyncJira200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  SyncJira200Response call({
    int found,
    int created,
    int? updated,
    int? waiting,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSyncJira200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSyncJira200Response.copyWith.fieldName(...)`
class _$SyncJira200ResponseCWProxyImpl implements _$SyncJira200ResponseCWProxy {
  const _$SyncJira200ResponseCWProxyImpl(this._value);

  final SyncJira200Response _value;

  @override
  SyncJira200Response found(int found) => this(found: found);

  @override
  SyncJira200Response created(int created) => this(created: created);

  @override
  SyncJira200Response updated(int? updated) => this(updated: updated);

  @override
  SyncJira200Response waiting(int? waiting) => this(waiting: waiting);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SyncJira200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SyncJira200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  SyncJira200Response call({
    Object? found = const $CopyWithPlaceholder(),
    Object? created = const $CopyWithPlaceholder(),
    Object? updated = const $CopyWithPlaceholder(),
    Object? waiting = const $CopyWithPlaceholder(),
  }) {
    return SyncJira200Response(
      found: found == const $CopyWithPlaceholder()
          ? _value.found
          // ignore: cast_nullable_to_non_nullable
          : found as int,
      created: created == const $CopyWithPlaceholder()
          ? _value.created
          // ignore: cast_nullable_to_non_nullable
          : created as int,
      updated: updated == const $CopyWithPlaceholder()
          ? _value.updated
          // ignore: cast_nullable_to_non_nullable
          : updated as int?,
      waiting: waiting == const $CopyWithPlaceholder()
          ? _value.waiting
          // ignore: cast_nullable_to_non_nullable
          : waiting as int?,
    );
  }
}

extension $SyncJira200ResponseCopyWith on SyncJira200Response {
  /// Returns a callable class that can be used as follows: `instanceOfSyncJira200Response.copyWith(...)` or like so:`instanceOfSyncJira200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SyncJira200ResponseCWProxy get copyWith =>
      _$SyncJira200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncJira200Response _$SyncJira200ResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SyncJira200Response', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['found', 'created']);
      final val = SyncJira200Response(
        found: $checkedConvert('found', (v) => (v as num).toInt()),
        created: $checkedConvert('created', (v) => (v as num).toInt()),
        updated: $checkedConvert('updated', (v) => (v as num?)?.toInt()),
        waiting: $checkedConvert('waiting', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$SyncJira200ResponseToJson(
  SyncJira200Response instance,
) => <String, dynamic>{
  'found': instance.found,
  'created': instance.created,
  'updated': ?instance.updated,
  'waiting': ?instance.waiting,
};
