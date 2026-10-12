// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guard_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GuardSettingsCWProxy {
  GuardSettings profile(GuardProfile profile);

  GuardSettings disabled(List<GuardHook> disabled);

  GuardSettings factCheck(int factCheck);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GuardSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GuardSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  GuardSettings call({
    GuardProfile profile,
    List<GuardHook> disabled,
    int factCheck,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGuardSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGuardSettings.copyWith.fieldName(...)`
class _$GuardSettingsCWProxyImpl implements _$GuardSettingsCWProxy {
  const _$GuardSettingsCWProxyImpl(this._value);

  final GuardSettings _value;

  @override
  GuardSettings profile(GuardProfile profile) => this(profile: profile);

  @override
  GuardSettings disabled(List<GuardHook> disabled) => this(disabled: disabled);

  @override
  GuardSettings factCheck(int factCheck) => this(factCheck: factCheck);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GuardSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GuardSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  GuardSettings call({
    Object? profile = const $CopyWithPlaceholder(),
    Object? disabled = const $CopyWithPlaceholder(),
    Object? factCheck = const $CopyWithPlaceholder(),
  }) {
    return GuardSettings(
      profile: profile == const $CopyWithPlaceholder()
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as GuardProfile,
      disabled: disabled == const $CopyWithPlaceholder()
          ? _value.disabled
          // ignore: cast_nullable_to_non_nullable
          : disabled as List<GuardHook>,
      factCheck: factCheck == const $CopyWithPlaceholder()
          ? _value.factCheck
          // ignore: cast_nullable_to_non_nullable
          : factCheck as int,
    );
  }
}

extension $GuardSettingsCopyWith on GuardSettings {
  /// Returns a callable class that can be used as follows: `instanceOfGuardSettings.copyWith(...)` or like so:`instanceOfGuardSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GuardSettingsCWProxy get copyWith => _$GuardSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuardSettings _$GuardSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GuardSettings', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['profile', 'disabled', 'factCheck'],
      );
      final val = GuardSettings(
        profile: $checkedConvert(
          'profile',
          (v) => $enumDecode(_$GuardProfileEnumMap, v),
        ),
        disabled: $checkedConvert(
          'disabled',
          (v) => (v as List<dynamic>)
              .map((e) => $enumDecode(_$GuardHookEnumMap, e))
              .toList(),
        ),
        factCheck: $checkedConvert('factCheck', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$GuardSettingsToJson(GuardSettings instance) =>
    <String, dynamic>{
      'profile': _$GuardProfileEnumMap[instance.profile]!,
      'disabled': instance.disabled.map((e) => _$GuardHookEnumMap[e]!).toList(),
      'factCheck': instance.factCheck,
    };

const _$GuardProfileEnumMap = {
  GuardProfile.minimal: 'minimal',
  GuardProfile.standard: 'standard',
  GuardProfile.strict: 'strict',
};

const _$GuardHookEnumMap = {
  GuardHook.preColonSecret: 'pre:secret',
  GuardHook.preColonRedflags: 'pre:redflags',
  GuardHook.preColonRules: 'pre:rules',
  GuardHook.preColonFactCheck: 'pre:fact-check',
  GuardHook.preColonDestructive: 'pre:destructive',
  GuardHook.postColonEditCheck: 'post:edit-check',
  GuardHook.stopColonGate: 'stop:gate',
  GuardHook.sessionColonProgress: 'session:progress',
};
