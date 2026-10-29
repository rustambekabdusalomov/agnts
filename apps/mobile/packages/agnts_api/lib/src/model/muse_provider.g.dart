// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muse_provider.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MuseProviderCWProxy {
  MuseProvider mode(MuseProviderMode mode);

  MuseProvider fallback(MuseProviderFallback? fallback);

  MuseProvider primaryOutUntil(DateTime? primaryOutUntil);

  MuseProvider primaryOutReason(String? primaryOutReason);

  MuseProvider setAt(DateTime? setAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MuseProvider(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MuseProvider(...).copyWith(id: 12, name: "My name")
  /// ````
  MuseProvider call({
    MuseProviderMode mode,
    MuseProviderFallback? fallback,
    DateTime? primaryOutUntil,
    String? primaryOutReason,
    DateTime? setAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMuseProvider.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMuseProvider.copyWith.fieldName(...)`
class _$MuseProviderCWProxyImpl implements _$MuseProviderCWProxy {
  const _$MuseProviderCWProxyImpl(this._value);

  final MuseProvider _value;

  @override
  MuseProvider mode(MuseProviderMode mode) => this(mode: mode);

  @override
  MuseProvider fallback(MuseProviderFallback? fallback) =>
      this(fallback: fallback);

  @override
  MuseProvider primaryOutUntil(DateTime? primaryOutUntil) =>
      this(primaryOutUntil: primaryOutUntil);

  @override
  MuseProvider primaryOutReason(String? primaryOutReason) =>
      this(primaryOutReason: primaryOutReason);

  @override
  MuseProvider setAt(DateTime? setAt) => this(setAt: setAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MuseProvider(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MuseProvider(...).copyWith(id: 12, name: "My name")
  /// ````
  MuseProvider call({
    Object? mode = const $CopyWithPlaceholder(),
    Object? fallback = const $CopyWithPlaceholder(),
    Object? primaryOutUntil = const $CopyWithPlaceholder(),
    Object? primaryOutReason = const $CopyWithPlaceholder(),
    Object? setAt = const $CopyWithPlaceholder(),
  }) {
    return MuseProvider(
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as MuseProviderMode,
      fallback: fallback == const $CopyWithPlaceholder()
          ? _value.fallback
          // ignore: cast_nullable_to_non_nullable
          : fallback as MuseProviderFallback?,
      primaryOutUntil: primaryOutUntil == const $CopyWithPlaceholder()
          ? _value.primaryOutUntil
          // ignore: cast_nullable_to_non_nullable
          : primaryOutUntil as DateTime?,
      primaryOutReason: primaryOutReason == const $CopyWithPlaceholder()
          ? _value.primaryOutReason
          // ignore: cast_nullable_to_non_nullable
          : primaryOutReason as String?,
      setAt: setAt == const $CopyWithPlaceholder()
          ? _value.setAt
          // ignore: cast_nullable_to_non_nullable
          : setAt as DateTime?,
    );
  }
}

extension $MuseProviderCopyWith on MuseProvider {
  /// Returns a callable class that can be used as follows: `instanceOfMuseProvider.copyWith(...)` or like so:`instanceOfMuseProvider.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MuseProviderCWProxy get copyWith => _$MuseProviderCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MuseProvider _$MuseProviderFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MuseProvider', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['mode']);
      final val = MuseProvider(
        mode: $checkedConvert(
          'mode',
          (v) => $enumDecode(_$MuseProviderModeEnumMap, v),
        ),
        fallback: $checkedConvert(
          'fallback',
          (v) => v == null
              ? null
              : MuseProviderFallback.fromJson(v as Map<String, dynamic>),
        ),
        primaryOutUntil: $checkedConvert(
          'primaryOutUntil',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        primaryOutReason: $checkedConvert(
          'primaryOutReason',
          (v) => v as String?,
        ),
        setAt: $checkedConvert(
          'setAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MuseProviderToJson(MuseProvider instance) =>
    <String, dynamic>{
      'mode': _$MuseProviderModeEnumMap[instance.mode]!,
      'fallback': ?instance.fallback?.toJson(),
      'primaryOutUntil': ?instance.primaryOutUntil?.toIso8601String(),
      'primaryOutReason': ?instance.primaryOutReason,
      'setAt': ?instance.setAt?.toIso8601String(),
    };

const _$MuseProviderModeEnumMap = {
  MuseProviderMode.auto: 'auto',
  MuseProviderMode.primary: 'primary',
  MuseProviderMode.fallback: 'fallback',
};
