// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_muse_provider_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetMuseProviderRequestCWProxy {
  SetMuseProviderRequest mode(MuseProviderMode mode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetMuseProviderRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetMuseProviderRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetMuseProviderRequest call({MuseProviderMode mode});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetMuseProviderRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetMuseProviderRequest.copyWith.fieldName(...)`
class _$SetMuseProviderRequestCWProxyImpl
    implements _$SetMuseProviderRequestCWProxy {
  const _$SetMuseProviderRequestCWProxyImpl(this._value);

  final SetMuseProviderRequest _value;

  @override
  SetMuseProviderRequest mode(MuseProviderMode mode) => this(mode: mode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetMuseProviderRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetMuseProviderRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetMuseProviderRequest call({Object? mode = const $CopyWithPlaceholder()}) {
    return SetMuseProviderRequest(
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as MuseProviderMode,
    );
  }
}

extension $SetMuseProviderRequestCopyWith on SetMuseProviderRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetMuseProviderRequest.copyWith(...)` or like so:`instanceOfSetMuseProviderRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetMuseProviderRequestCWProxy get copyWith =>
      _$SetMuseProviderRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetMuseProviderRequest _$SetMuseProviderRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetMuseProviderRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['mode']);
  final val = SetMuseProviderRequest(
    mode: $checkedConvert(
      'mode',
      (v) => $enumDecode(_$MuseProviderModeEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$SetMuseProviderRequestToJson(
  SetMuseProviderRequest instance,
) => <String, dynamic>{'mode': _$MuseProviderModeEnumMap[instance.mode]!};

const _$MuseProviderModeEnumMap = {
  MuseProviderMode.auto: 'auto',
  MuseProviderMode.primary: 'primary',
  MuseProviderMode.fallback: 'fallback',
};
