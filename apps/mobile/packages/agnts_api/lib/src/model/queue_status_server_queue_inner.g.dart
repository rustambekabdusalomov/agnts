// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_status_server_queue_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QueueStatusServerQueueInnerCWProxy {
  QueueStatusServerQueueInner key(String key);

  QueueStatusServerQueueInner position(int position);

  QueueStatusServerQueueInner others(int others);

  QueueStatusServerQueueInner estimateSec(int? estimateSec);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QueueStatusServerQueueInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QueueStatusServerQueueInner(...).copyWith(id: 12, name: "My name")
  /// ````
  QueueStatusServerQueueInner call({
    String key,
    int position,
    int others,
    int? estimateSec,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfQueueStatusServerQueueInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfQueueStatusServerQueueInner.copyWith.fieldName(...)`
class _$QueueStatusServerQueueInnerCWProxyImpl
    implements _$QueueStatusServerQueueInnerCWProxy {
  const _$QueueStatusServerQueueInnerCWProxyImpl(this._value);

  final QueueStatusServerQueueInner _value;

  @override
  QueueStatusServerQueueInner key(String key) => this(key: key);

  @override
  QueueStatusServerQueueInner position(int position) =>
      this(position: position);

  @override
  QueueStatusServerQueueInner others(int others) => this(others: others);

  @override
  QueueStatusServerQueueInner estimateSec(int? estimateSec) =>
      this(estimateSec: estimateSec);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QueueStatusServerQueueInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QueueStatusServerQueueInner(...).copyWith(id: 12, name: "My name")
  /// ````
  QueueStatusServerQueueInner call({
    Object? key = const $CopyWithPlaceholder(),
    Object? position = const $CopyWithPlaceholder(),
    Object? others = const $CopyWithPlaceholder(),
    Object? estimateSec = const $CopyWithPlaceholder(),
  }) {
    return QueueStatusServerQueueInner(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      position: position == const $CopyWithPlaceholder()
          ? _value.position
          // ignore: cast_nullable_to_non_nullable
          : position as int,
      others: others == const $CopyWithPlaceholder()
          ? _value.others
          // ignore: cast_nullable_to_non_nullable
          : others as int,
      estimateSec: estimateSec == const $CopyWithPlaceholder()
          ? _value.estimateSec
          // ignore: cast_nullable_to_non_nullable
          : estimateSec as int?,
    );
  }
}

extension $QueueStatusServerQueueInnerCopyWith on QueueStatusServerQueueInner {
  /// Returns a callable class that can be used as follows: `instanceOfQueueStatusServerQueueInner.copyWith(...)` or like so:`instanceOfQueueStatusServerQueueInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QueueStatusServerQueueInnerCWProxy get copyWith =>
      _$QueueStatusServerQueueInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueStatusServerQueueInner _$QueueStatusServerQueueInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('QueueStatusServerQueueInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['key', 'position', 'others']);
  final val = QueueStatusServerQueueInner(
    key: $checkedConvert('key', (v) => v as String),
    position: $checkedConvert('position', (v) => (v as num).toInt()),
    others: $checkedConvert('others', (v) => (v as num).toInt()),
    estimateSec: $checkedConvert('estimateSec', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$QueueStatusServerQueueInnerToJson(
  QueueStatusServerQueueInner instance,
) => <String, dynamic>{
  'key': instance.key,
  'position': instance.position,
  'others': instance.others,
  'estimateSec': ?instance.estimateSec,
};
