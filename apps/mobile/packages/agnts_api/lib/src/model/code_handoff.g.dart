// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_handoff.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CodeHandoffCWProxy {
  CodeHandoff request(String request);

  CodeHandoff repoIds(List<int> repoIds);

  CodeHandoff repos(List<String> repos);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeHandoff(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeHandoff(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeHandoff call({String request, List<int> repoIds, List<String> repos});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCodeHandoff.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCodeHandoff.copyWith.fieldName(...)`
class _$CodeHandoffCWProxyImpl implements _$CodeHandoffCWProxy {
  const _$CodeHandoffCWProxyImpl(this._value);

  final CodeHandoff _value;

  @override
  CodeHandoff request(String request) => this(request: request);

  @override
  CodeHandoff repoIds(List<int> repoIds) => this(repoIds: repoIds);

  @override
  CodeHandoff repos(List<String> repos) => this(repos: repos);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeHandoff(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeHandoff(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeHandoff call({
    Object? request = const $CopyWithPlaceholder(),
    Object? repoIds = const $CopyWithPlaceholder(),
    Object? repos = const $CopyWithPlaceholder(),
  }) {
    return CodeHandoff(
      request: request == const $CopyWithPlaceholder()
          ? _value.request
          // ignore: cast_nullable_to_non_nullable
          : request as String,
      repoIds: repoIds == const $CopyWithPlaceholder()
          ? _value.repoIds
          // ignore: cast_nullable_to_non_nullable
          : repoIds as List<int>,
      repos: repos == const $CopyWithPlaceholder()
          ? _value.repos
          // ignore: cast_nullable_to_non_nullable
          : repos as List<String>,
    );
  }
}

extension $CodeHandoffCopyWith on CodeHandoff {
  /// Returns a callable class that can be used as follows: `instanceOfCodeHandoff.copyWith(...)` or like so:`instanceOfCodeHandoff.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CodeHandoffCWProxy get copyWith => _$CodeHandoffCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeHandoff _$CodeHandoffFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CodeHandoff', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['request', 'repoIds', 'repos']);
      final val = CodeHandoff(
        request: $checkedConvert('request', (v) => v as String),
        repoIds: $checkedConvert(
          'repoIds',
          (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
        repos: $checkedConvert(
          'repos',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CodeHandoffToJson(CodeHandoff instance) =>
    <String, dynamic>{
      'request': instance.request,
      'repoIds': instance.repoIds,
      'repos': instance.repos,
    };
