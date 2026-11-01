// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_service.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogServiceCWProxy {
  LogService id(int? id);

  LogService name(String name);

  LogService selector(String selector);

  LogService repoIds(List<int> repoIds);

  LogService groupId(int? groupId);

  LogService enabled(bool enabled);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogService(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogService(...).copyWith(id: 12, name: "My name")
  /// ````
  LogService call({
    int? id,
    String name,
    String selector,
    List<int> repoIds,
    int? groupId,
    bool enabled,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogService.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogService.copyWith.fieldName(...)`
class _$LogServiceCWProxyImpl implements _$LogServiceCWProxy {
  const _$LogServiceCWProxyImpl(this._value);

  final LogService _value;

  @override
  LogService id(int? id) => this(id: id);

  @override
  LogService name(String name) => this(name: name);

  @override
  LogService selector(String selector) => this(selector: selector);

  @override
  LogService repoIds(List<int> repoIds) => this(repoIds: repoIds);

  @override
  LogService groupId(int? groupId) => this(groupId: groupId);

  @override
  LogService enabled(bool enabled) => this(enabled: enabled);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogService(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogService(...).copyWith(id: 12, name: "My name")
  /// ````
  LogService call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? selector = const $CopyWithPlaceholder(),
    Object? repoIds = const $CopyWithPlaceholder(),
    Object? groupId = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
  }) {
    return LogService(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      selector: selector == const $CopyWithPlaceholder()
          ? _value.selector
          // ignore: cast_nullable_to_non_nullable
          : selector as String,
      repoIds: repoIds == const $CopyWithPlaceholder()
          ? _value.repoIds
          // ignore: cast_nullable_to_non_nullable
          : repoIds as List<int>,
      groupId: groupId == const $CopyWithPlaceholder()
          ? _value.groupId
          // ignore: cast_nullable_to_non_nullable
          : groupId as int?,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
    );
  }
}

extension $LogServiceCopyWith on LogService {
  /// Returns a callable class that can be used as follows: `instanceOfLogService.copyWith(...)` or like so:`instanceOfLogService.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogServiceCWProxy get copyWith => _$LogServiceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogService _$LogServiceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogService', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['name', 'selector', 'repoIds', 'enabled'],
      );
      final val = LogService(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String),
        selector: $checkedConvert('selector', (v) => v as String),
        repoIds: $checkedConvert(
          'repoIds',
          (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
        groupId: $checkedConvert('groupId', (v) => (v as num?)?.toInt()),
        enabled: $checkedConvert('enabled', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$LogServiceToJson(LogService instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': instance.name,
      'selector': instance.selector,
      'repoIds': instance.repoIds,
      'groupId': ?instance.groupId,
      'enabled': instance.enabled,
    };
