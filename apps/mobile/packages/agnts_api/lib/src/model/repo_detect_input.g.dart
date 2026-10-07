// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_detect_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoDetectInputCWProxy {
  RepoDetectInput id(int? id);

  RepoDetectInput cloneUrl(String? cloneUrl);

  RepoDetectInput defaultBranch(String? defaultBranch);

  RepoDetectInput deep(bool? deep);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoDetectInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoDetectInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoDetectInput call({
    int? id,
    String? cloneUrl,
    String? defaultBranch,
    bool? deep,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoDetectInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoDetectInput.copyWith.fieldName(...)`
class _$RepoDetectInputCWProxyImpl implements _$RepoDetectInputCWProxy {
  const _$RepoDetectInputCWProxyImpl(this._value);

  final RepoDetectInput _value;

  @override
  RepoDetectInput id(int? id) => this(id: id);

  @override
  RepoDetectInput cloneUrl(String? cloneUrl) => this(cloneUrl: cloneUrl);

  @override
  RepoDetectInput defaultBranch(String? defaultBranch) =>
      this(defaultBranch: defaultBranch);

  @override
  RepoDetectInput deep(bool? deep) => this(deep: deep);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoDetectInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoDetectInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoDetectInput call({
    Object? id = const $CopyWithPlaceholder(),
    Object? cloneUrl = const $CopyWithPlaceholder(),
    Object? defaultBranch = const $CopyWithPlaceholder(),
    Object? deep = const $CopyWithPlaceholder(),
  }) {
    return RepoDetectInput(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      cloneUrl: cloneUrl == const $CopyWithPlaceholder()
          ? _value.cloneUrl
          // ignore: cast_nullable_to_non_nullable
          : cloneUrl as String?,
      defaultBranch: defaultBranch == const $CopyWithPlaceholder()
          ? _value.defaultBranch
          // ignore: cast_nullable_to_non_nullable
          : defaultBranch as String?,
      deep: deep == const $CopyWithPlaceholder()
          ? _value.deep
          // ignore: cast_nullable_to_non_nullable
          : deep as bool?,
    );
  }
}

extension $RepoDetectInputCopyWith on RepoDetectInput {
  /// Returns a callable class that can be used as follows: `instanceOfRepoDetectInput.copyWith(...)` or like so:`instanceOfRepoDetectInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoDetectInputCWProxy get copyWith => _$RepoDetectInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoDetectInput _$RepoDetectInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoDetectInput', json, ($checkedConvert) {
      final val = RepoDetectInput(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        cloneUrl: $checkedConvert('cloneUrl', (v) => v as String?),
        defaultBranch: $checkedConvert('defaultBranch', (v) => v as String?),
        deep: $checkedConvert('deep', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$RepoDetectInputToJson(RepoDetectInput instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'cloneUrl': ?instance.cloneUrl,
      'defaultBranch': ?instance.defaultBranch,
      'deep': ?instance.deep,
    };
