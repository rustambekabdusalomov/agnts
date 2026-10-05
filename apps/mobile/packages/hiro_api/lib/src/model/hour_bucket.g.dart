// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hour_bucket.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HourBucketCWProxy {
  HourBucket hour(int hour);

  HourBucket hiro(int hiro);

  HourBucket you(int you);

  HourBucket problems(int problems);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HourBucket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HourBucket(...).copyWith(id: 12, name: "My name")
  /// ````
  HourBucket call({int hour, int hiro, int you, int problems});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHourBucket.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHourBucket.copyWith.fieldName(...)`
class _$HourBucketCWProxyImpl implements _$HourBucketCWProxy {
  const _$HourBucketCWProxyImpl(this._value);

  final HourBucket _value;

  @override
  HourBucket hour(int hour) => this(hour: hour);

  @override
  HourBucket hiro(int hiro) => this(hiro: hiro);

  @override
  HourBucket you(int you) => this(you: you);

  @override
  HourBucket problems(int problems) => this(problems: problems);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HourBucket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HourBucket(...).copyWith(id: 12, name: "My name")
  /// ````
  HourBucket call({
    Object? hour = const $CopyWithPlaceholder(),
    Object? hiro = const $CopyWithPlaceholder(),
    Object? you = const $CopyWithPlaceholder(),
    Object? problems = const $CopyWithPlaceholder(),
  }) {
    return HourBucket(
      hour: hour == const $CopyWithPlaceholder()
          ? _value.hour
          // ignore: cast_nullable_to_non_nullable
          : hour as int,
      hiro: hiro == const $CopyWithPlaceholder()
          ? _value.hiro
          // ignore: cast_nullable_to_non_nullable
          : hiro as int,
      you: you == const $CopyWithPlaceholder()
          ? _value.you
          // ignore: cast_nullable_to_non_nullable
          : you as int,
      problems: problems == const $CopyWithPlaceholder()
          ? _value.problems
          // ignore: cast_nullable_to_non_nullable
          : problems as int,
    );
  }
}

extension $HourBucketCopyWith on HourBucket {
  /// Returns a callable class that can be used as follows: `instanceOfHourBucket.copyWith(...)` or like so:`instanceOfHourBucket.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HourBucketCWProxy get copyWith => _$HourBucketCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HourBucket _$HourBucketFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HourBucket', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['hour', 'hiro', 'you', 'problems']);
      final val = HourBucket(
        hour: $checkedConvert('hour', (v) => (v as num).toInt()),
        hiro: $checkedConvert('hiro', (v) => (v as num).toInt()),
        you: $checkedConvert('you', (v) => (v as num).toInt()),
        problems: $checkedConvert('problems', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$HourBucketToJson(HourBucket instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'hiro': instance.hiro,
      'you': instance.you,
      'problems': instance.problems,
    };
