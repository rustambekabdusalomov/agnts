// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EventCWProxy {
  Event id(int id);

  Event ticketKey(String ticketKey);

  Event runId(int? runId);

  Event step(String step);

  Event type(String type);

  Event level(EventLevelEnum level);

  Event origin(EventOriginEnum origin);

  Event message(String message);

  Event data(Map<String, Object> data);

  Event durationMs(int? durationMs);

  Event user(String? user);

  Event createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Event(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Event(...).copyWith(id: 12, name: "My name")
  /// ````
  Event call({
    int id,
    String ticketKey,
    int? runId,
    String step,
    String type,
    EventLevelEnum level,
    EventOriginEnum origin,
    String message,
    Map<String, Object> data,
    int? durationMs,
    String? user,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEvent.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEvent.copyWith.fieldName(...)`
class _$EventCWProxyImpl implements _$EventCWProxy {
  const _$EventCWProxyImpl(this._value);

  final Event _value;

  @override
  Event id(int id) => this(id: id);

  @override
  Event ticketKey(String ticketKey) => this(ticketKey: ticketKey);

  @override
  Event runId(int? runId) => this(runId: runId);

  @override
  Event step(String step) => this(step: step);

  @override
  Event type(String type) => this(type: type);

  @override
  Event level(EventLevelEnum level) => this(level: level);

  @override
  Event origin(EventOriginEnum origin) => this(origin: origin);

  @override
  Event message(String message) => this(message: message);

  @override
  Event data(Map<String, Object> data) => this(data: data);

  @override
  Event durationMs(int? durationMs) => this(durationMs: durationMs);

  @override
  Event user(String? user) => this(user: user);

  @override
  Event createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Event(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Event(...).copyWith(id: 12, name: "My name")
  /// ````
  Event call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? runId = const $CopyWithPlaceholder(),
    Object? step = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? level = const $CopyWithPlaceholder(),
    Object? origin = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
    Object? durationMs = const $CopyWithPlaceholder(),
    Object? user = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return Event(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String,
      runId: runId == const $CopyWithPlaceholder()
          ? _value.runId
          // ignore: cast_nullable_to_non_nullable
          : runId as int?,
      step: step == const $CopyWithPlaceholder()
          ? _value.step
          // ignore: cast_nullable_to_non_nullable
          : step as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
      level: level == const $CopyWithPlaceholder()
          ? _value.level
          // ignore: cast_nullable_to_non_nullable
          : level as EventLevelEnum,
      origin: origin == const $CopyWithPlaceholder()
          ? _value.origin
          // ignore: cast_nullable_to_non_nullable
          : origin as EventOriginEnum,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Map<String, Object>,
      durationMs: durationMs == const $CopyWithPlaceholder()
          ? _value.durationMs
          // ignore: cast_nullable_to_non_nullable
          : durationMs as int?,
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $EventCopyWith on Event {
  /// Returns a callable class that can be used as follows: `instanceOfEvent.copyWith(...)` or like so:`instanceOfEvent.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EventCWProxy get copyWith => _$EventCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Event', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'ticketKey',
      'step',
      'type',
      'level',
      'origin',
      'message',
      'data',
      'createdAt',
    ],
  );
  final val = Event(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    ticketKey: $checkedConvert('ticketKey', (v) => v as String),
    runId: $checkedConvert('runId', (v) => (v as num?)?.toInt()),
    step: $checkedConvert('step', (v) => v as String),
    type: $checkedConvert('type', (v) => v as String),
    level: $checkedConvert(
      'level',
      (v) => $enumDecode(_$EventLevelEnumEnumMap, v),
    ),
    origin: $checkedConvert(
      'origin',
      (v) => $enumDecode(_$EventOriginEnumEnumMap, v),
    ),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) =>
          (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
    ),
    durationMs: $checkedConvert('durationMs', (v) => (v as num?)?.toInt()),
    user: $checkedConvert('user', (v) => v as String?),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'ticketKey': instance.ticketKey,
  'runId': ?instance.runId,
  'step': instance.step,
  'type': instance.type,
  'level': _$EventLevelEnumEnumMap[instance.level]!,
  'origin': _$EventOriginEnumEnumMap[instance.origin]!,
  'message': instance.message,
  'data': instance.data,
  'durationMs': ?instance.durationMs,
  'user': ?instance.user,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$EventLevelEnumEnumMap = {
  EventLevelEnum.debug: 'debug',
  EventLevelEnum.info: 'info',
  EventLevelEnum.warn: 'warn',
  EventLevelEnum.error: 'error',
};

const _$EventOriginEnumEnumMap = {
  EventOriginEnum.system: 'system',
  EventOriginEnum.web: 'web',
  EventOriginEnum.mobile: 'mobile',
  EventOriginEnum.mcp: 'mcp',
  EventOriginEnum.telegram: 'telegram',
  EventOriginEnum.webhook: 'webhook',
};
