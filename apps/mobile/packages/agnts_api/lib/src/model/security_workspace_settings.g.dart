// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_workspace_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecurityWorkspaceSettingsCWProxy {
  SecurityWorkspaceSettings autoCheck(bool autoCheck);

  SecurityWorkspaceSettings dailyBudget(int dailyBudget);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecurityWorkspaceSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecurityWorkspaceSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  SecurityWorkspaceSettings call({bool autoCheck, int dailyBudget});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecurityWorkspaceSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecurityWorkspaceSettings.copyWith.fieldName(...)`
class _$SecurityWorkspaceSettingsCWProxyImpl
    implements _$SecurityWorkspaceSettingsCWProxy {
  const _$SecurityWorkspaceSettingsCWProxyImpl(this._value);

  final SecurityWorkspaceSettings _value;

  @override
  SecurityWorkspaceSettings autoCheck(bool autoCheck) =>
      this(autoCheck: autoCheck);

  @override
  SecurityWorkspaceSettings dailyBudget(int dailyBudget) =>
      this(dailyBudget: dailyBudget);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecurityWorkspaceSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecurityWorkspaceSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  SecurityWorkspaceSettings call({
    Object? autoCheck = const $CopyWithPlaceholder(),
    Object? dailyBudget = const $CopyWithPlaceholder(),
  }) {
    return SecurityWorkspaceSettings(
      autoCheck: autoCheck == const $CopyWithPlaceholder()
          ? _value.autoCheck
          // ignore: cast_nullable_to_non_nullable
          : autoCheck as bool,
      dailyBudget: dailyBudget == const $CopyWithPlaceholder()
          ? _value.dailyBudget
          // ignore: cast_nullable_to_non_nullable
          : dailyBudget as int,
    );
  }
}

extension $SecurityWorkspaceSettingsCopyWith on SecurityWorkspaceSettings {
  /// Returns a callable class that can be used as follows: `instanceOfSecurityWorkspaceSettings.copyWith(...)` or like so:`instanceOfSecurityWorkspaceSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecurityWorkspaceSettingsCWProxy get copyWith =>
      _$SecurityWorkspaceSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityWorkspaceSettings _$SecurityWorkspaceSettingsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SecurityWorkspaceSettings', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['autoCheck', 'dailyBudget']);
  final val = SecurityWorkspaceSettings(
    autoCheck: $checkedConvert('autoCheck', (v) => v as bool),
    dailyBudget: $checkedConvert('dailyBudget', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$SecurityWorkspaceSettingsToJson(
  SecurityWorkspaceSettings instance,
) => <String, dynamic>{
  'autoCheck': instance.autoCheck,
  'dailyBudget': instance.dailyBudget,
};
