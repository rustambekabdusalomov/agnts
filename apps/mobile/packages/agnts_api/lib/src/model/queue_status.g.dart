// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_status.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QueueStatusCWProxy {
  QueueStatus running(int running);

  QueueStatus slots(int slots);

  QueueStatus waiting(QueueStatusWaiting waiting);

  QueueStatus serverQueue(List<QueueStatusServerQueueInner> serverQueue);

  QueueStatus serverQueueLength(int serverQueueLength);

  QueueStatus capacity(Capacity capacity);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QueueStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QueueStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  QueueStatus call({
    int running,
    int slots,
    QueueStatusWaiting waiting,
    List<QueueStatusServerQueueInner> serverQueue,
    int serverQueueLength,
    Capacity capacity,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfQueueStatus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfQueueStatus.copyWith.fieldName(...)`
class _$QueueStatusCWProxyImpl implements _$QueueStatusCWProxy {
  const _$QueueStatusCWProxyImpl(this._value);

  final QueueStatus _value;

  @override
  QueueStatus running(int running) => this(running: running);

  @override
  QueueStatus slots(int slots) => this(slots: slots);

  @override
  QueueStatus waiting(QueueStatusWaiting waiting) => this(waiting: waiting);

  @override
  QueueStatus serverQueue(List<QueueStatusServerQueueInner> serverQueue) =>
      this(serverQueue: serverQueue);

  @override
  QueueStatus serverQueueLength(int serverQueueLength) =>
      this(serverQueueLength: serverQueueLength);

  @override
  QueueStatus capacity(Capacity capacity) => this(capacity: capacity);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QueueStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QueueStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  QueueStatus call({
    Object? running = const $CopyWithPlaceholder(),
    Object? slots = const $CopyWithPlaceholder(),
    Object? waiting = const $CopyWithPlaceholder(),
    Object? serverQueue = const $CopyWithPlaceholder(),
    Object? serverQueueLength = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
  }) {
    return QueueStatus(
      running: running == const $CopyWithPlaceholder()
          ? _value.running
          // ignore: cast_nullable_to_non_nullable
          : running as int,
      slots: slots == const $CopyWithPlaceholder()
          ? _value.slots
          // ignore: cast_nullable_to_non_nullable
          : slots as int,
      waiting: waiting == const $CopyWithPlaceholder()
          ? _value.waiting
          // ignore: cast_nullable_to_non_nullable
          : waiting as QueueStatusWaiting,
      serverQueue: serverQueue == const $CopyWithPlaceholder()
          ? _value.serverQueue
          // ignore: cast_nullable_to_non_nullable
          : serverQueue as List<QueueStatusServerQueueInner>,
      serverQueueLength: serverQueueLength == const $CopyWithPlaceholder()
          ? _value.serverQueueLength
          // ignore: cast_nullable_to_non_nullable
          : serverQueueLength as int,
      capacity: capacity == const $CopyWithPlaceholder()
          ? _value.capacity
          // ignore: cast_nullable_to_non_nullable
          : capacity as Capacity,
    );
  }
}

extension $QueueStatusCopyWith on QueueStatus {
  /// Returns a callable class that can be used as follows: `instanceOfQueueStatus.copyWith(...)` or like so:`instanceOfQueueStatus.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QueueStatusCWProxy get copyWith => _$QueueStatusCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueStatus _$QueueStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate('QueueStatus', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'running',
          'slots',
          'waiting',
          'serverQueue',
          'serverQueueLength',
          'capacity',
        ],
      );
      final val = QueueStatus(
        running: $checkedConvert('running', (v) => (v as num).toInt()),
        slots: $checkedConvert('slots', (v) => (v as num).toInt()),
        waiting: $checkedConvert(
          'waiting',
          (v) => QueueStatusWaiting.fromJson(v as Map<String, dynamic>),
        ),
        serverQueue: $checkedConvert(
          'serverQueue',
          (v) => (v as List<dynamic>)
              .map(
                (e) => QueueStatusServerQueueInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
        serverQueueLength: $checkedConvert(
          'serverQueueLength',
          (v) => (v as num).toInt(),
        ),
        capacity: $checkedConvert(
          'capacity',
          (v) => Capacity.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$QueueStatusToJson(QueueStatus instance) =>
    <String, dynamic>{
      'running': instance.running,
      'slots': instance.slots,
      'waiting': instance.waiting.toJson(),
      'serverQueue': instance.serverQueue.map((e) => e.toJson()).toList(),
      'serverQueueLength': instance.serverQueueLength,
      'capacity': instance.capacity.toJson(),
    };
