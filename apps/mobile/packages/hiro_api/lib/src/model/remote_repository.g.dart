// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_repository.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RemoteRepositoryCWProxy {
  RemoteRepository fullName(String fullName);

  RemoteRepository cloneUrl(String cloneUrl);

  RemoteRepository defaultBranch(String defaultBranch);

  RemoteRepository private(bool private);

  RemoteRepository description(String? description);

  RemoteRepository updatedAt(DateTime? updatedAt);

  RemoteRepository added(bool added);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RemoteRepository(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RemoteRepository(...).copyWith(id: 12, name: "My name")
  /// ````
  RemoteRepository call({
    String fullName,
    String cloneUrl,
    String defaultBranch,
    bool private,
    String? description,
    DateTime? updatedAt,
    bool added,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRemoteRepository.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRemoteRepository.copyWith.fieldName(...)`
class _$RemoteRepositoryCWProxyImpl implements _$RemoteRepositoryCWProxy {
  const _$RemoteRepositoryCWProxyImpl(this._value);

  final RemoteRepository _value;

  @override
  RemoteRepository fullName(String fullName) => this(fullName: fullName);

  @override
  RemoteRepository cloneUrl(String cloneUrl) => this(cloneUrl: cloneUrl);

  @override
  RemoteRepository defaultBranch(String defaultBranch) =>
      this(defaultBranch: defaultBranch);

  @override
  RemoteRepository private(bool private) => this(private: private);

  @override
  RemoteRepository description(String? description) =>
      this(description: description);

  @override
  RemoteRepository updatedAt(DateTime? updatedAt) => this(updatedAt: updatedAt);

  @override
  RemoteRepository added(bool added) => this(added: added);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RemoteRepository(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RemoteRepository(...).copyWith(id: 12, name: "My name")
  /// ````
  RemoteRepository call({
    Object? fullName = const $CopyWithPlaceholder(),
    Object? cloneUrl = const $CopyWithPlaceholder(),
    Object? defaultBranch = const $CopyWithPlaceholder(),
    Object? private = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? added = const $CopyWithPlaceholder(),
  }) {
    return RemoteRepository(
      fullName: fullName == const $CopyWithPlaceholder()
          ? _value.fullName
          // ignore: cast_nullable_to_non_nullable
          : fullName as String,
      cloneUrl: cloneUrl == const $CopyWithPlaceholder()
          ? _value.cloneUrl
          // ignore: cast_nullable_to_non_nullable
          : cloneUrl as String,
      defaultBranch: defaultBranch == const $CopyWithPlaceholder()
          ? _value.defaultBranch
          // ignore: cast_nullable_to_non_nullable
          : defaultBranch as String,
      private: private == const $CopyWithPlaceholder()
          ? _value.private
          // ignore: cast_nullable_to_non_nullable
          : private as bool,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      added: added == const $CopyWithPlaceholder()
          ? _value.added
          // ignore: cast_nullable_to_non_nullable
          : added as bool,
    );
  }
}

extension $RemoteRepositoryCopyWith on RemoteRepository {
  /// Returns a callable class that can be used as follows: `instanceOfRemoteRepository.copyWith(...)` or like so:`instanceOfRemoteRepository.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RemoteRepositoryCWProxy get copyWith => _$RemoteRepositoryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteRepository _$RemoteRepositoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RemoteRepository', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'fullName',
          'cloneUrl',
          'defaultBranch',
          'private',
          'added',
        ],
      );
      final val = RemoteRepository(
        fullName: $checkedConvert('fullName', (v) => v as String),
        cloneUrl: $checkedConvert('cloneUrl', (v) => v as String),
        defaultBranch: $checkedConvert('defaultBranch', (v) => v as String),
        private: $checkedConvert('private', (v) => v as bool),
        description: $checkedConvert('description', (v) => v as String?),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        added: $checkedConvert('added', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$RemoteRepositoryToJson(RemoteRepository instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'cloneUrl': instance.cloneUrl,
      'defaultBranch': instance.defaultBranch,
      'private': instance.private,
      'description': ?instance.description,
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
      'added': instance.added,
    };
