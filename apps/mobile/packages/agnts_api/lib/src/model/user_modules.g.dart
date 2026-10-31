// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_modules.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserModulesCWProxy {
  UserModules own(List<Module>? own);

  UserModules effective(List<Module> effective);

  UserModules setAt(DateTime? setAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserModules(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserModules(...).copyWith(id: 12, name: "My name")
  /// ````
  UserModules call({
    List<Module>? own,
    List<Module> effective,
    DateTime? setAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUserModules.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUserModules.copyWith.fieldName(...)`
class _$UserModulesCWProxyImpl implements _$UserModulesCWProxy {
  const _$UserModulesCWProxyImpl(this._value);

  final UserModules _value;

  @override
  UserModules own(List<Module>? own) => this(own: own);

  @override
  UserModules effective(List<Module> effective) => this(effective: effective);

  @override
  UserModules setAt(DateTime? setAt) => this(setAt: setAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserModules(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserModules(...).copyWith(id: 12, name: "My name")
  /// ````
  UserModules call({
    Object? own = const $CopyWithPlaceholder(),
    Object? effective = const $CopyWithPlaceholder(),
    Object? setAt = const $CopyWithPlaceholder(),
  }) {
    return UserModules(
      own: own == const $CopyWithPlaceholder()
          ? _value.own
          // ignore: cast_nullable_to_non_nullable
          : own as List<Module>?,
      effective: effective == const $CopyWithPlaceholder()
          ? _value.effective
          // ignore: cast_nullable_to_non_nullable
          : effective as List<Module>,
      setAt: setAt == const $CopyWithPlaceholder()
          ? _value.setAt
          // ignore: cast_nullable_to_non_nullable
          : setAt as DateTime?,
    );
  }
}

extension $UserModulesCopyWith on UserModules {
  /// Returns a callable class that can be used as follows: `instanceOfUserModules.copyWith(...)` or like so:`instanceOfUserModules.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserModulesCWProxy get copyWith => _$UserModulesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModules _$UserModulesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserModules', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['effective']);
      final val = UserModules(
        own: $checkedConvert(
          'own',
          (v) => (v as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ModuleEnumMap, e))
              .toList(),
        ),
        effective: $checkedConvert(
          'effective',
          (v) => (v as List<dynamic>)
              .map((e) => $enumDecode(_$ModuleEnumMap, e))
              .toList(),
        ),
        setAt: $checkedConvert(
          'setAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UserModulesToJson(UserModules instance) =>
    <String, dynamic>{
      'own': ?instance.own?.map((e) => _$ModuleEnumMap[e]!).toList(),
      'effective': instance.effective.map((e) => _$ModuleEnumMap[e]!).toList(),
      'setAt': ?instance.setAt?.toIso8601String(),
    };

const _$ModuleEnumMap = {
  Module.muse: 'muse',
  Module.claude: 'claude',
  Module.codex: 'codex',
};
