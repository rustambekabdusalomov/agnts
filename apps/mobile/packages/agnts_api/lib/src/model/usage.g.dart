// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UsageCWProxy {
  Usage fiveHour(UsageWindow fiveHour);

  Usage sevenDay(UsageWindow sevenDay);

  Usage status(UsageStatusEnum status);

  Usage updatedAt(DateTime? updatedAt);

  Usage paused(bool paused);

  Usage pausedUntil(DateTime? pausedUntil);

  Usage pauseAbove(int pauseAbove);

  Usage refreshing(bool refreshing);

  Usage provider(UsageProviderEnum? provider);

  Usage connected(bool? connected);

  Usage account(String? account);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Usage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Usage(...).copyWith(id: 12, name: "My name")
  /// ````
  Usage call({
    UsageWindow fiveHour,
    UsageWindow sevenDay,
    UsageStatusEnum status,
    DateTime? updatedAt,
    bool paused,
    DateTime? pausedUntil,
    int pauseAbove,
    bool refreshing,
    UsageProviderEnum? provider,
    bool? connected,
    String? account,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUsage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUsage.copyWith.fieldName(...)`
class _$UsageCWProxyImpl implements _$UsageCWProxy {
  const _$UsageCWProxyImpl(this._value);

  final Usage _value;

  @override
  Usage fiveHour(UsageWindow fiveHour) => this(fiveHour: fiveHour);

  @override
  Usage sevenDay(UsageWindow sevenDay) => this(sevenDay: sevenDay);

  @override
  Usage status(UsageStatusEnum status) => this(status: status);

  @override
  Usage updatedAt(DateTime? updatedAt) => this(updatedAt: updatedAt);

  @override
  Usage paused(bool paused) => this(paused: paused);

  @override
  Usage pausedUntil(DateTime? pausedUntil) => this(pausedUntil: pausedUntil);

  @override
  Usage pauseAbove(int pauseAbove) => this(pauseAbove: pauseAbove);

  @override
  Usage refreshing(bool refreshing) => this(refreshing: refreshing);

  @override
  Usage provider(UsageProviderEnum? provider) => this(provider: provider);

  @override
  Usage connected(bool? connected) => this(connected: connected);

  @override
  Usage account(String? account) => this(account: account);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Usage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Usage(...).copyWith(id: 12, name: "My name")
  /// ````
  Usage call({
    Object? fiveHour = const $CopyWithPlaceholder(),
    Object? sevenDay = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? paused = const $CopyWithPlaceholder(),
    Object? pausedUntil = const $CopyWithPlaceholder(),
    Object? pauseAbove = const $CopyWithPlaceholder(),
    Object? refreshing = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? connected = const $CopyWithPlaceholder(),
    Object? account = const $CopyWithPlaceholder(),
  }) {
    return Usage(
      fiveHour: fiveHour == const $CopyWithPlaceholder()
          ? _value.fiveHour
          // ignore: cast_nullable_to_non_nullable
          : fiveHour as UsageWindow,
      sevenDay: sevenDay == const $CopyWithPlaceholder()
          ? _value.sevenDay
          // ignore: cast_nullable_to_non_nullable
          : sevenDay as UsageWindow,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as UsageStatusEnum,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      paused: paused == const $CopyWithPlaceholder()
          ? _value.paused
          // ignore: cast_nullable_to_non_nullable
          : paused as bool,
      pausedUntil: pausedUntil == const $CopyWithPlaceholder()
          ? _value.pausedUntil
          // ignore: cast_nullable_to_non_nullable
          : pausedUntil as DateTime?,
      pauseAbove: pauseAbove == const $CopyWithPlaceholder()
          ? _value.pauseAbove
          // ignore: cast_nullable_to_non_nullable
          : pauseAbove as int,
      refreshing: refreshing == const $CopyWithPlaceholder()
          ? _value.refreshing
          // ignore: cast_nullable_to_non_nullable
          : refreshing as bool,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as UsageProviderEnum?,
      connected: connected == const $CopyWithPlaceholder()
          ? _value.connected
          // ignore: cast_nullable_to_non_nullable
          : connected as bool?,
      account: account == const $CopyWithPlaceholder()
          ? _value.account
          // ignore: cast_nullable_to_non_nullable
          : account as String?,
    );
  }
}

extension $UsageCopyWith on Usage {
  /// Returns a callable class that can be used as follows: `instanceOfUsage.copyWith(...)` or like so:`instanceOfUsage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UsageCWProxy get copyWith => _$UsageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usage _$UsageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Usage', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'fiveHour',
          'sevenDay',
          'status',
          'paused',
          'pauseAbove',
          'refreshing',
        ],
      );
      final val = Usage(
        fiveHour: $checkedConvert(
          'fiveHour',
          (v) => UsageWindow.fromJson(v as Map<String, dynamic>),
        ),
        sevenDay: $checkedConvert(
          'sevenDay',
          (v) => UsageWindow.fromJson(v as Map<String, dynamic>),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$UsageStatusEnumEnumMap, v),
        ),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        paused: $checkedConvert('paused', (v) => v as bool),
        pausedUntil: $checkedConvert(
          'pausedUntil',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        pauseAbove: $checkedConvert('pauseAbove', (v) => (v as num).toInt()),
        refreshing: $checkedConvert('refreshing', (v) => v as bool),
        provider: $checkedConvert(
          'provider',
          (v) => $enumDecodeNullable(_$UsageProviderEnumEnumMap, v),
        ),
        connected: $checkedConvert('connected', (v) => v as bool?),
        account: $checkedConvert('account', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$UsageToJson(Usage instance) => <String, dynamic>{
  'fiveHour': instance.fiveHour.toJson(),
  'sevenDay': instance.sevenDay.toJson(),
  'status': _$UsageStatusEnumEnumMap[instance.status]!,
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
  'paused': instance.paused,
  'pausedUntil': ?instance.pausedUntil?.toIso8601String(),
  'pauseAbove': instance.pauseAbove,
  'refreshing': instance.refreshing,
  'provider': ?_$UsageProviderEnumEnumMap[instance.provider],
  'connected': ?instance.connected,
  'account': ?instance.account,
};

const _$UsageStatusEnumEnumMap = {
  UsageStatusEnum.allowed: 'allowed',
  UsageStatusEnum.allowedWarning: 'allowed_warning',
  UsageStatusEnum.rejected: 'rejected',
  UsageStatusEnum.unknown: 'unknown',
};

const _$UsageProviderEnumEnumMap = {
  UsageProviderEnum.muse: 'muse',
  UsageProviderEnum.claude: 'claude',
};
