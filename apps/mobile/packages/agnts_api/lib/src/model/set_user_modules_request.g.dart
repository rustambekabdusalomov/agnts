// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_user_modules_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetUserModulesRequestCWProxy {
  SetUserModulesRequest modules(List<Module>? modules);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetUserModulesRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetUserModulesRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetUserModulesRequest call({List<Module>? modules});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetUserModulesRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetUserModulesRequest.copyWith.fieldName(...)`
class _$SetUserModulesRequestCWProxyImpl
    implements _$SetUserModulesRequestCWProxy {
  const _$SetUserModulesRequestCWProxyImpl(this._value);

  final SetUserModulesRequest _value;

  @override
  SetUserModulesRequest modules(List<Module>? modules) =>
      this(modules: modules);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetUserModulesRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetUserModulesRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetUserModulesRequest call({Object? modules = const $CopyWithPlaceholder()}) {
    return SetUserModulesRequest(
      modules: modules == const $CopyWithPlaceholder()
          ? _value.modules
          // ignore: cast_nullable_to_non_nullable
          : modules as List<Module>?,
    );
  }
}

extension $SetUserModulesRequestCopyWith on SetUserModulesRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetUserModulesRequest.copyWith(...)` or like so:`instanceOfSetUserModulesRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetUserModulesRequestCWProxy get copyWith =>
      _$SetUserModulesRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetUserModulesRequest _$SetUserModulesRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetUserModulesRequest', json, ($checkedConvert) {
  final val = SetUserModulesRequest(
    modules: $checkedConvert(
      'modules',
      (v) => (v as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ModuleEnumMap, e))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$SetUserModulesRequestToJson(
  SetUserModulesRequest instance,
) => <String, dynamic>{
  'modules': ?instance.modules?.map((e) => _$ModuleEnumMap[e]!).toList(),
};

const _$ModuleEnumMap = {
  Module.muse: 'muse',
  Module.claude: 'claude',
  Module.codex: 'codex',
};
