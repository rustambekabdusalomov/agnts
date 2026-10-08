// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_workspace_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateWorkspaceRequestCWProxy {
  CreateWorkspaceRequest name(String name);

  CreateWorkspaceRequest slug(String? slug);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateWorkspaceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateWorkspaceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateWorkspaceRequest call({String name, String? slug});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateWorkspaceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateWorkspaceRequest.copyWith.fieldName(...)`
class _$CreateWorkspaceRequestCWProxyImpl
    implements _$CreateWorkspaceRequestCWProxy {
  const _$CreateWorkspaceRequestCWProxyImpl(this._value);

  final CreateWorkspaceRequest _value;

  @override
  CreateWorkspaceRequest name(String name) => this(name: name);

  @override
  CreateWorkspaceRequest slug(String? slug) => this(slug: slug);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateWorkspaceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateWorkspaceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateWorkspaceRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? slug = const $CopyWithPlaceholder(),
  }) {
    return CreateWorkspaceRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      slug: slug == const $CopyWithPlaceholder()
          ? _value.slug
          // ignore: cast_nullable_to_non_nullable
          : slug as String?,
    );
  }
}

extension $CreateWorkspaceRequestCopyWith on CreateWorkspaceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateWorkspaceRequest.copyWith(...)` or like so:`instanceOfCreateWorkspaceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateWorkspaceRequestCWProxy get copyWith =>
      _$CreateWorkspaceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateWorkspaceRequest _$CreateWorkspaceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateWorkspaceRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['name']);
  final val = CreateWorkspaceRequest(
    name: $checkedConvert('name', (v) => v as String),
    slug: $checkedConvert('slug', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$CreateWorkspaceRequestToJson(
  CreateWorkspaceRequest instance,
) => <String, dynamic>{'name': instance.name, 'slug': ?instance.slug};
