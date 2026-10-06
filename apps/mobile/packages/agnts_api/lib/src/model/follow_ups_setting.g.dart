// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_ups_setting.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FollowUpsSettingCWProxy {
  FollowUpsSetting mode(FollowUpsMode mode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FollowUpsSetting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FollowUpsSetting(...).copyWith(id: 12, name: "My name")
  /// ````
  FollowUpsSetting call({FollowUpsMode mode});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFollowUpsSetting.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFollowUpsSetting.copyWith.fieldName(...)`
class _$FollowUpsSettingCWProxyImpl implements _$FollowUpsSettingCWProxy {
  const _$FollowUpsSettingCWProxyImpl(this._value);

  final FollowUpsSetting _value;

  @override
  FollowUpsSetting mode(FollowUpsMode mode) => this(mode: mode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FollowUpsSetting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FollowUpsSetting(...).copyWith(id: 12, name: "My name")
  /// ````
  FollowUpsSetting call({Object? mode = const $CopyWithPlaceholder()}) {
    return FollowUpsSetting(
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as FollowUpsMode,
    );
  }
}

extension $FollowUpsSettingCopyWith on FollowUpsSetting {
  /// Returns a callable class that can be used as follows: `instanceOfFollowUpsSetting.copyWith(...)` or like so:`instanceOfFollowUpsSetting.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FollowUpsSettingCWProxy get copyWith => _$FollowUpsSettingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowUpsSetting _$FollowUpsSettingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FollowUpsSetting', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['mode']);
      final val = FollowUpsSetting(
        mode: $checkedConvert(
          'mode',
          (v) => $enumDecode(_$FollowUpsModeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$FollowUpsSettingToJson(FollowUpsSetting instance) =>
    <String, dynamic>{'mode': _$FollowUpsModeEnumMap[instance.mode]!};

const _$FollowUpsModeEnumMap = {
  FollowUpsMode.inherit: 'inherit',
  FollowUpsMode.on_: 'on',
  FollowUpsMode.off: 'off',
};
