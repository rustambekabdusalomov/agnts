// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_commit_message_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EditCommitMessageRequestCWProxy {
  EditCommitMessageRequest sha(String sha);

  EditCommitMessageRequest message(String message);

  EditCommitMessageRequest repoId(int? repoId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EditCommitMessageRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EditCommitMessageRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EditCommitMessageRequest call({String sha, String message, int? repoId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEditCommitMessageRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEditCommitMessageRequest.copyWith.fieldName(...)`
class _$EditCommitMessageRequestCWProxyImpl
    implements _$EditCommitMessageRequestCWProxy {
  const _$EditCommitMessageRequestCWProxyImpl(this._value);

  final EditCommitMessageRequest _value;

  @override
  EditCommitMessageRequest sha(String sha) => this(sha: sha);

  @override
  EditCommitMessageRequest message(String message) => this(message: message);

  @override
  EditCommitMessageRequest repoId(int? repoId) => this(repoId: repoId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EditCommitMessageRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EditCommitMessageRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EditCommitMessageRequest call({
    Object? sha = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
  }) {
    return EditCommitMessageRequest(
      sha: sha == const $CopyWithPlaceholder()
          ? _value.sha
          // ignore: cast_nullable_to_non_nullable
          : sha as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
    );
  }
}

extension $EditCommitMessageRequestCopyWith on EditCommitMessageRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEditCommitMessageRequest.copyWith(...)` or like so:`instanceOfEditCommitMessageRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EditCommitMessageRequestCWProxy get copyWith =>
      _$EditCommitMessageRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditCommitMessageRequest _$EditCommitMessageRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EditCommitMessageRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['sha', 'message']);
  final val = EditCommitMessageRequest(
    sha: $checkedConvert('sha', (v) => v as String),
    message: $checkedConvert('message', (v) => v as String),
    repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$EditCommitMessageRequestToJson(
  EditCommitMessageRequest instance,
) => <String, dynamic>{
  'sha': instance.sha,
  'message': instance.message,
  'repoId': ?instance.repoId,
};
