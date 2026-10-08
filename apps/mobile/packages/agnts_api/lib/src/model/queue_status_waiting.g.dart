// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_status_waiting.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QueueStatusWaitingCWProxy {
  QueueStatusWaiting blocked(int? blocked);

  QueueStatusWaiting slots(int? slots);

  QueueStatusWaiting server(int? server);

  QueueStatusWaiting claude(int? claude);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QueueStatusWaiting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QueueStatusWaiting(...).copyWith(id: 12, name: "My name")
  /// ````
  QueueStatusWaiting call({int? blocked, int? slots, int? server, int? claude});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfQueueStatusWaiting.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfQueueStatusWaiting.copyWith.fieldName(...)`
class _$QueueStatusWaitingCWProxyImpl implements _$QueueStatusWaitingCWProxy {
  const _$QueueStatusWaitingCWProxyImpl(this._value);

  final QueueStatusWaiting _value;

  @override
  QueueStatusWaiting blocked(int? blocked) => this(blocked: blocked);

  @override
  QueueStatusWaiting slots(int? slots) => this(slots: slots);

  @override
  QueueStatusWaiting server(int? server) => this(server: server);

  @override
  QueueStatusWaiting claude(int? claude) => this(claude: claude);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QueueStatusWaiting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QueueStatusWaiting(...).copyWith(id: 12, name: "My name")
  /// ````
  QueueStatusWaiting call({
    Object? blocked = const $CopyWithPlaceholder(),
    Object? slots = const $CopyWithPlaceholder(),
    Object? server = const $CopyWithPlaceholder(),
    Object? claude = const $CopyWithPlaceholder(),
  }) {
    return QueueStatusWaiting(
      blocked: blocked == const $CopyWithPlaceholder()
          ? _value.blocked
          // ignore: cast_nullable_to_non_nullable
          : blocked as int?,
      slots: slots == const $CopyWithPlaceholder()
          ? _value.slots
          // ignore: cast_nullable_to_non_nullable
          : slots as int?,
      server: server == const $CopyWithPlaceholder()
          ? _value.server
          // ignore: cast_nullable_to_non_nullable
          : server as int?,
      claude: claude == const $CopyWithPlaceholder()
          ? _value.claude
          // ignore: cast_nullable_to_non_nullable
          : claude as int?,
    );
  }
}

extension $QueueStatusWaitingCopyWith on QueueStatusWaiting {
  /// Returns a callable class that can be used as follows: `instanceOfQueueStatusWaiting.copyWith(...)` or like so:`instanceOfQueueStatusWaiting.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QueueStatusWaitingCWProxy get copyWith =>
      _$QueueStatusWaitingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueStatusWaiting _$QueueStatusWaitingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('QueueStatusWaiting', json, ($checkedConvert) {
      final val = QueueStatusWaiting(
        blocked: $checkedConvert('blocked', (v) => (v as num?)?.toInt()),
        slots: $checkedConvert('slots', (v) => (v as num?)?.toInt()),
        server: $checkedConvert('server', (v) => (v as num?)?.toInt()),
        claude: $checkedConvert('claude', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$QueueStatusWaitingToJson(QueueStatusWaiting instance) =>
    <String, dynamic>{
      'blocked': ?instance.blocked,
      'slots': ?instance.slots,
      'server': ?instance.server,
      'claude': ?instance.claude,
    };
