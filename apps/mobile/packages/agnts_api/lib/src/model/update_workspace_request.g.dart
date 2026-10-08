// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_workspace_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateWorkspaceRequestCWProxy {
  UpdateWorkspaceRequest name(String? name);

  UpdateWorkspaceRequest slug(String? slug);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateWorkspaceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateWorkspaceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateWorkspaceRequest call({String? name, String? slug});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateWorkspaceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateWorkspaceRequest.copyWith.fieldName(...)`
class _$UpdateWorkspaceRequestCWProxyImpl
    implements _$UpdateWorkspaceRequestCWProxy {
  const _$UpdateWorkspaceRequestCWProxyImpl(this._value);

  final UpdateWorkspaceRequest _value;

  @override
  UpdateWorkspaceRequest name(String? name) => this(name: name);

  @override
  UpdateWorkspaceRequest slug(String? slug) => this(slug: slug);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateWorkspaceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateWorkspaceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateWorkspaceRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? slug = const $CopyWithPlaceholder(),
  }) {
    return UpdateWorkspaceRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      slug: slug == const $CopyWithPlaceholder()
          ? _value.slug
          // ignore: cast_nullable_to_non_nullable
          : slug as String?,
    );
  }
}

extension $UpdateWorkspaceRequestCopyWith on UpdateWorkspaceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateWorkspaceRequest.copyWith(...)` or like so:`instanceOfUpdateWorkspaceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateWorkspaceRequestCWProxy get copyWith =>
      _$UpdateWorkspaceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateWorkspaceRequest _$UpdateWorkspaceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateWorkspaceRequest', json, ($checkedConvert) {
  final val = UpdateWorkspaceRequest(
    name: $checkedConvert('name', (v) => v as String?),
    slug: $checkedConvert('slug', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$UpdateWorkspaceRequestToJson(
  UpdateWorkspaceRequest instance,
) => <String, dynamic>{'name': ?instance.name, 'slug': ?instance.slug};
