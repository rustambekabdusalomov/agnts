// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_commit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BranchCommitCWProxy {
  BranchCommit sha(String sha);

  BranchCommit message(String message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BranchCommit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BranchCommit(...).copyWith(id: 12, name: "My name")
  /// ````
  BranchCommit call({String sha, String message});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBranchCommit.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBranchCommit.copyWith.fieldName(...)`
class _$BranchCommitCWProxyImpl implements _$BranchCommitCWProxy {
  const _$BranchCommitCWProxyImpl(this._value);

  final BranchCommit _value;

  @override
  BranchCommit sha(String sha) => this(sha: sha);

  @override
  BranchCommit message(String message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BranchCommit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BranchCommit(...).copyWith(id: 12, name: "My name")
  /// ````
  BranchCommit call({
    Object? sha = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return BranchCommit(
      sha: sha == const $CopyWithPlaceholder()
          ? _value.sha
          // ignore: cast_nullable_to_non_nullable
          : sha as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
    );
  }
}

extension $BranchCommitCopyWith on BranchCommit {
  /// Returns a callable class that can be used as follows: `instanceOfBranchCommit.copyWith(...)` or like so:`instanceOfBranchCommit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BranchCommitCWProxy get copyWith => _$BranchCommitCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchCommit _$BranchCommitFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BranchCommit', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['sha', 'message']);
      final val = BranchCommit(
        sha: $checkedConvert('sha', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$BranchCommitToJson(BranchCommit instance) =>
    <String, dynamic>{'sha': instance.sha, 'message': instance.message};
