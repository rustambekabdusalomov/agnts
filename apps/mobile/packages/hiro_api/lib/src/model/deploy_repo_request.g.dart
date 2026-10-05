// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deploy_repo_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeployRepoRequestCWProxy {
  DeployRepoRequest jobId(int? jobId);

  DeployRepoRequest ref(String? ref);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeployRepoRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeployRepoRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DeployRepoRequest call({int? jobId, String? ref});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeployRepoRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeployRepoRequest.copyWith.fieldName(...)`
class _$DeployRepoRequestCWProxyImpl implements _$DeployRepoRequestCWProxy {
  const _$DeployRepoRequestCWProxyImpl(this._value);

  final DeployRepoRequest _value;

  @override
  DeployRepoRequest jobId(int? jobId) => this(jobId: jobId);

  @override
  DeployRepoRequest ref(String? ref) => this(ref: ref);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeployRepoRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeployRepoRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DeployRepoRequest call({
    Object? jobId = const $CopyWithPlaceholder(),
    Object? ref = const $CopyWithPlaceholder(),
  }) {
    return DeployRepoRequest(
      jobId: jobId == const $CopyWithPlaceholder()
          ? _value.jobId
          // ignore: cast_nullable_to_non_nullable
          : jobId as int?,
      ref: ref == const $CopyWithPlaceholder()
          ? _value.ref
          // ignore: cast_nullable_to_non_nullable
          : ref as String?,
    );
  }
}

extension $DeployRepoRequestCopyWith on DeployRepoRequest {
  /// Returns a callable class that can be used as follows: `instanceOfDeployRepoRequest.copyWith(...)` or like so:`instanceOfDeployRepoRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeployRepoRequestCWProxy get copyWith =>
      _$DeployRepoRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeployRepoRequest _$DeployRepoRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DeployRepoRequest', json, ($checkedConvert) {
      final val = DeployRepoRequest(
        jobId: $checkedConvert('jobId', (v) => (v as num?)?.toInt()),
        ref: $checkedConvert('ref', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$DeployRepoRequestToJson(DeployRepoRequest instance) =>
    <String, dynamic>{'jobId': ?instance.jobId, 'ref': ?instance.ref};
