// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modules_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ModulesSettingsCWProxy {
  ModulesSettings available(List<Module> available);

  ModulesSettings enabled(List<Module> enabled);

  ModulesSettings default_(List<Module> default_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModulesSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModulesSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  ModulesSettings call({
    List<Module> available,
    List<Module> enabled,
    List<Module> default_,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfModulesSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfModulesSettings.copyWith.fieldName(...)`
class _$ModulesSettingsCWProxyImpl implements _$ModulesSettingsCWProxy {
  const _$ModulesSettingsCWProxyImpl(this._value);

  final ModulesSettings _value;

  @override
  ModulesSettings available(List<Module> available) =>
      this(available: available);

  @override
  ModulesSettings enabled(List<Module> enabled) => this(enabled: enabled);

  @override
  ModulesSettings default_(List<Module> default_) => this(default_: default_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ModulesSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ModulesSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  ModulesSettings call({
    Object? available = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? default_ = const $CopyWithPlaceholder(),
  }) {
    return ModulesSettings(
      available: available == const $CopyWithPlaceholder()
          ? _value.available
          // ignore: cast_nullable_to_non_nullable
          : available as List<Module>,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as List<Module>,
      default_: default_ == const $CopyWithPlaceholder()
          ? _value.default_
          // ignore: cast_nullable_to_non_nullable
          : default_ as List<Module>,
    );
  }
}

extension $ModulesSettingsCopyWith on ModulesSettings {
  /// Returns a callable class that can be used as follows: `instanceOfModulesSettings.copyWith(...)` or like so:`instanceOfModulesSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ModulesSettingsCWProxy get copyWith => _$ModulesSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModulesSettings _$ModulesSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ModulesSettings', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['available', 'enabled', 'default']);
      final val = ModulesSettings(
        available: $checkedConvert(
          'available',
          (v) => (v as List<dynamic>)
              .map((e) => $enumDecode(_$ModuleEnumMap, e))
              .toList(),
        ),
        enabled: $checkedConvert(
          'enabled',
          (v) => (v as List<dynamic>)
              .map((e) => $enumDecode(_$ModuleEnumMap, e))
              .toList(),
        ),
        default_: $checkedConvert(
          'default',
          (v) => (v as List<dynamic>)
              .map((e) => $enumDecode(_$ModuleEnumMap, e))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'default_': 'default'});

Map<String, dynamic> _$ModulesSettingsToJson(ModulesSettings instance) =>
    <String, dynamic>{
      'available': instance.available.map((e) => _$ModuleEnumMap[e]!).toList(),
      'enabled': instance.enabled.map((e) => _$ModuleEnumMap[e]!).toList(),
      'default': instance.default_.map((e) => _$ModuleEnumMap[e]!).toList(),
    };

const _$ModuleEnumMap = {
  Module.muse: 'muse',
  Module.claude: 'claude',
  Module.codex: 'codex',
};
