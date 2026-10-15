// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_suite_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerSuiteInputCWProxy {
  SwaggerSuiteInput fromTicket(String? fromTicket);

  SwaggerSuiteInput name(String? name);

  SwaggerSuiteInput schedule(SwaggerSuiteInputScheduleEnum? schedule);

  SwaggerSuiteInput hour(int? hour);

  SwaggerSuiteInput enabled(bool? enabled);

  SwaggerSuiteInput token(String? token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSuiteInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSuiteInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSuiteInput call({
    String? fromTicket,
    String? name,
    SwaggerSuiteInputScheduleEnum? schedule,
    int? hour,
    bool? enabled,
    String? token,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerSuiteInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerSuiteInput.copyWith.fieldName(...)`
class _$SwaggerSuiteInputCWProxyImpl implements _$SwaggerSuiteInputCWProxy {
  const _$SwaggerSuiteInputCWProxyImpl(this._value);

  final SwaggerSuiteInput _value;

  @override
  SwaggerSuiteInput fromTicket(String? fromTicket) =>
      this(fromTicket: fromTicket);

  @override
  SwaggerSuiteInput name(String? name) => this(name: name);

  @override
  SwaggerSuiteInput schedule(SwaggerSuiteInputScheduleEnum? schedule) =>
      this(schedule: schedule);

  @override
  SwaggerSuiteInput hour(int? hour) => this(hour: hour);

  @override
  SwaggerSuiteInput enabled(bool? enabled) => this(enabled: enabled);

  @override
  SwaggerSuiteInput token(String? token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerSuiteInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerSuiteInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerSuiteInput call({
    Object? fromTicket = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? schedule = const $CopyWithPlaceholder(),
    Object? hour = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
  }) {
    return SwaggerSuiteInput(
      fromTicket: fromTicket == const $CopyWithPlaceholder()
          ? _value.fromTicket
          // ignore: cast_nullable_to_non_nullable
          : fromTicket as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      schedule: schedule == const $CopyWithPlaceholder()
          ? _value.schedule
          // ignore: cast_nullable_to_non_nullable
          : schedule as SwaggerSuiteInputScheduleEnum?,
      hour: hour == const $CopyWithPlaceholder()
          ? _value.hour
          // ignore: cast_nullable_to_non_nullable
          : hour as int?,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool?,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String?,
    );
  }
}

extension $SwaggerSuiteInputCopyWith on SwaggerSuiteInput {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerSuiteInput.copyWith(...)` or like so:`instanceOfSwaggerSuiteInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerSuiteInputCWProxy get copyWith =>
      _$SwaggerSuiteInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerSuiteInput _$SwaggerSuiteInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwaggerSuiteInput', json, ($checkedConvert) {
      final val = SwaggerSuiteInput(
        fromTicket: $checkedConvert('fromTicket', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        schedule: $checkedConvert(
          'schedule',
          (v) => $enumDecodeNullable(_$SwaggerSuiteInputScheduleEnumEnumMap, v),
        ),
        hour: $checkedConvert('hour', (v) => (v as num?)?.toInt()),
        enabled: $checkedConvert('enabled', (v) => v as bool?),
        token: $checkedConvert('token', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SwaggerSuiteInputToJson(SwaggerSuiteInput instance) =>
    <String, dynamic>{
      'fromTicket': ?instance.fromTicket,
      'name': ?instance.name,
      'schedule': ?_$SwaggerSuiteInputScheduleEnumEnumMap[instance.schedule],
      'hour': ?instance.hour,
      'enabled': ?instance.enabled,
      'token': ?instance.token,
    };

const _$SwaggerSuiteInputScheduleEnumEnumMap = {
  SwaggerSuiteInputScheduleEnum.off: 'off',
  SwaggerSuiteInputScheduleEnum.hourly: 'hourly',
  SwaggerSuiteInputScheduleEnum.daily: 'daily',
  SwaggerSuiteInputScheduleEnum.weekly: 'weekly',
};
