// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_server_variables_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerServerVariablesInnerCWProxy {
  SwaggerServerVariablesInner name(String name);

  SwaggerServerVariablesInner default_(String default_);

  SwaggerServerVariablesInner enum_(List<String>? enum_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerServerVariablesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerServerVariablesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerServerVariablesInner call({
    String name,
    String default_,
    List<String>? enum_,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerServerVariablesInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerServerVariablesInner.copyWith.fieldName(...)`
class _$SwaggerServerVariablesInnerCWProxyImpl
    implements _$SwaggerServerVariablesInnerCWProxy {
  const _$SwaggerServerVariablesInnerCWProxyImpl(this._value);

  final SwaggerServerVariablesInner _value;

  @override
  SwaggerServerVariablesInner name(String name) => this(name: name);

  @override
  SwaggerServerVariablesInner default_(String default_) =>
      this(default_: default_);

  @override
  SwaggerServerVariablesInner enum_(List<String>? enum_) => this(enum_: enum_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerServerVariablesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerServerVariablesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerServerVariablesInner call({
    Object? name = const $CopyWithPlaceholder(),
    Object? default_ = const $CopyWithPlaceholder(),
    Object? enum_ = const $CopyWithPlaceholder(),
  }) {
    return SwaggerServerVariablesInner(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      default_: default_ == const $CopyWithPlaceholder()
          ? _value.default_
          // ignore: cast_nullable_to_non_nullable
          : default_ as String,
      enum_: enum_ == const $CopyWithPlaceholder()
          ? _value.enum_
          // ignore: cast_nullable_to_non_nullable
          : enum_ as List<String>?,
    );
  }
}

extension $SwaggerServerVariablesInnerCopyWith on SwaggerServerVariablesInner {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerServerVariablesInner.copyWith(...)` or like so:`instanceOfSwaggerServerVariablesInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerServerVariablesInnerCWProxy get copyWith =>
      _$SwaggerServerVariablesInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerServerVariablesInner _$SwaggerServerVariablesInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'SwaggerServerVariablesInner',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['name', 'default']);
    final val = SwaggerServerVariablesInner(
      name: $checkedConvert('name', (v) => v as String),
      default_: $checkedConvert('default', (v) => v as String),
      enum_: $checkedConvert(
        'enum',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'default_': 'default', 'enum_': 'enum'},
);

Map<String, dynamic> _$SwaggerServerVariablesInnerToJson(
  SwaggerServerVariablesInner instance,
) => <String, dynamic>{
  'name': instance.name,
  'default': instance.default_,
  'enum': ?instance.enum_,
};
