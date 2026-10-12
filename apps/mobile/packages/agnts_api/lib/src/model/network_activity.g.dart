// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_activity.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NetworkActivityCWProxy {
  NetworkActivity today(int today);

  NetworkActivity refused(int refused);

  NetworkActivity dials(List<NetworkActivityDialsInner> dials);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkActivity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkActivity(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkActivity call({
    int today,
    int refused,
    List<NetworkActivityDialsInner> dials,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNetworkActivity.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNetworkActivity.copyWith.fieldName(...)`
class _$NetworkActivityCWProxyImpl implements _$NetworkActivityCWProxy {
  const _$NetworkActivityCWProxyImpl(this._value);

  final NetworkActivity _value;

  @override
  NetworkActivity today(int today) => this(today: today);

  @override
  NetworkActivity refused(int refused) => this(refused: refused);

  @override
  NetworkActivity dials(List<NetworkActivityDialsInner> dials) =>
      this(dials: dials);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NetworkActivity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NetworkActivity(...).copyWith(id: 12, name: "My name")
  /// ````
  NetworkActivity call({
    Object? today = const $CopyWithPlaceholder(),
    Object? refused = const $CopyWithPlaceholder(),
    Object? dials = const $CopyWithPlaceholder(),
  }) {
    return NetworkActivity(
      today: today == const $CopyWithPlaceholder()
          ? _value.today
          // ignore: cast_nullable_to_non_nullable
          : today as int,
      refused: refused == const $CopyWithPlaceholder()
          ? _value.refused
          // ignore: cast_nullable_to_non_nullable
          : refused as int,
      dials: dials == const $CopyWithPlaceholder()
          ? _value.dials
          // ignore: cast_nullable_to_non_nullable
          : dials as List<NetworkActivityDialsInner>,
    );
  }
}

extension $NetworkActivityCopyWith on NetworkActivity {
  /// Returns a callable class that can be used as follows: `instanceOfNetworkActivity.copyWith(...)` or like so:`instanceOfNetworkActivity.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NetworkActivityCWProxy get copyWith => _$NetworkActivityCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkActivity _$NetworkActivityFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NetworkActivity', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['today', 'refused', 'dials']);
      final val = NetworkActivity(
        today: $checkedConvert('today', (v) => (v as num).toInt()),
        refused: $checkedConvert('refused', (v) => (v as num).toInt()),
        dials: $checkedConvert(
          'dials',
          (v) => (v as List<dynamic>)
              .map(
                (e) => NetworkActivityDialsInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$NetworkActivityToJson(NetworkActivity instance) =>
    <String, dynamic>{
      'today': instance.today,
      'refused': instance.refused,
      'dials': instance.dials.map((e) => e.toJson()).toList(),
    };
