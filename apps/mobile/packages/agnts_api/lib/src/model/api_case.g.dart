// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiCaseCWProxy {
  ApiCase id(String id);

  ApiCase operation(String operation);

  ApiCase case_(String case_);

  ApiCase expected(String? expected);

  ApiCase verdict(ApiCaseVerdictEnum verdict);

  ApiCase reason(String? reason);

  ApiCase requests(List<String> requests);

  ApiCase source_(ApiCaseSource_Enum source_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiCase(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiCase(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiCase call({
    String id,
    String operation,
    String case_,
    String? expected,
    ApiCaseVerdictEnum verdict,
    String? reason,
    List<String> requests,
    ApiCaseSource_Enum source_,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiCase.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiCase.copyWith.fieldName(...)`
class _$ApiCaseCWProxyImpl implements _$ApiCaseCWProxy {
  const _$ApiCaseCWProxyImpl(this._value);

  final ApiCase _value;

  @override
  ApiCase id(String id) => this(id: id);

  @override
  ApiCase operation(String operation) => this(operation: operation);

  @override
  ApiCase case_(String case_) => this(case_: case_);

  @override
  ApiCase expected(String? expected) => this(expected: expected);

  @override
  ApiCase verdict(ApiCaseVerdictEnum verdict) => this(verdict: verdict);

  @override
  ApiCase reason(String? reason) => this(reason: reason);

  @override
  ApiCase requests(List<String> requests) => this(requests: requests);

  @override
  ApiCase source_(ApiCaseSource_Enum source_) => this(source_: source_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiCase(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiCase(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiCase call({
    Object? id = const $CopyWithPlaceholder(),
    Object? operation = const $CopyWithPlaceholder(),
    Object? case_ = const $CopyWithPlaceholder(),
    Object? expected = const $CopyWithPlaceholder(),
    Object? verdict = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? requests = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
  }) {
    return ApiCase(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      operation: operation == const $CopyWithPlaceholder()
          ? _value.operation
          // ignore: cast_nullable_to_non_nullable
          : operation as String,
      case_: case_ == const $CopyWithPlaceholder()
          ? _value.case_
          // ignore: cast_nullable_to_non_nullable
          : case_ as String,
      expected: expected == const $CopyWithPlaceholder()
          ? _value.expected
          // ignore: cast_nullable_to_non_nullable
          : expected as String?,
      verdict: verdict == const $CopyWithPlaceholder()
          ? _value.verdict
          // ignore: cast_nullable_to_non_nullable
          : verdict as ApiCaseVerdictEnum,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      requests: requests == const $CopyWithPlaceholder()
          ? _value.requests
          // ignore: cast_nullable_to_non_nullable
          : requests as List<String>,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as ApiCaseSource_Enum,
    );
  }
}

extension $ApiCaseCopyWith on ApiCase {
  /// Returns a callable class that can be used as follows: `instanceOfApiCase.copyWith(...)` or like so:`instanceOfApiCase.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiCaseCWProxy get copyWith => _$ApiCaseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiCase _$ApiCaseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiCase', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'operation',
          'case',
          'verdict',
          'requests',
          'source',
        ],
      );
      final val = ApiCase(
        id: $checkedConvert('id', (v) => v as String),
        operation: $checkedConvert('operation', (v) => v as String),
        case_: $checkedConvert('case', (v) => v as String),
        expected: $checkedConvert('expected', (v) => v as String?),
        verdict: $checkedConvert(
          'verdict',
          (v) => $enumDecode(_$ApiCaseVerdictEnumEnumMap, v),
        ),
        reason: $checkedConvert('reason', (v) => v as String?),
        requests: $checkedConvert(
          'requests',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        source_: $checkedConvert(
          'source',
          (v) => $enumDecode(_$ApiCaseSource_EnumEnumMap, v),
        ),
      );
      return val;
    }, fieldKeyMap: const {'case_': 'case', 'source_': 'source'});

Map<String, dynamic> _$ApiCaseToJson(ApiCase instance) => <String, dynamic>{
  'id': instance.id,
  'operation': instance.operation,
  'case': instance.case_,
  'expected': ?instance.expected,
  'verdict': _$ApiCaseVerdictEnumEnumMap[instance.verdict]!,
  'reason': ?instance.reason,
  'requests': instance.requests,
  'source': _$ApiCaseSource_EnumEnumMap[instance.source_]!,
};

const _$ApiCaseVerdictEnumEnumMap = {
  ApiCaseVerdictEnum.pass: 'pass',
  ApiCaseVerdictEnum.fail: 'fail',
  ApiCaseVerdictEnum.skipped: 'skipped',
  ApiCaseVerdictEnum.blocked: 'blocked',
};

const _$ApiCaseSource_EnumEnumMap = {
  ApiCaseSource_Enum.claude: 'claude',
  ApiCaseSource_Enum.schema: 'schema',
};
