// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secret_findings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecretFindingsCWProxy {
  SecretFindings code(String code);

  SecretFindings message(String message);

  SecretFindings findings(List<SecretFindingsFindingsInner> findings);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecretFindings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecretFindings(...).copyWith(id: 12, name: "My name")
  /// ````
  SecretFindings call({
    String code,
    String message,
    List<SecretFindingsFindingsInner> findings,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecretFindings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecretFindings.copyWith.fieldName(...)`
class _$SecretFindingsCWProxyImpl implements _$SecretFindingsCWProxy {
  const _$SecretFindingsCWProxyImpl(this._value);

  final SecretFindings _value;

  @override
  SecretFindings code(String code) => this(code: code);

  @override
  SecretFindings message(String message) => this(message: message);

  @override
  SecretFindings findings(List<SecretFindingsFindingsInner> findings) =>
      this(findings: findings);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecretFindings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecretFindings(...).copyWith(id: 12, name: "My name")
  /// ````
  SecretFindings call({
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? findings = const $CopyWithPlaceholder(),
  }) {
    return SecretFindings(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      findings: findings == const $CopyWithPlaceholder()
          ? _value.findings
          // ignore: cast_nullable_to_non_nullable
          : findings as List<SecretFindingsFindingsInner>,
    );
  }
}

extension $SecretFindingsCopyWith on SecretFindings {
  /// Returns a callable class that can be used as follows: `instanceOfSecretFindings.copyWith(...)` or like so:`instanceOfSecretFindings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecretFindingsCWProxy get copyWith => _$SecretFindingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecretFindings _$SecretFindingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SecretFindings', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'message', 'findings']);
      final val = SecretFindings(
        code: $checkedConvert('code', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        findings: $checkedConvert(
          'findings',
          (v) => (v as List<dynamic>)
              .map(
                (e) => SecretFindingsFindingsInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SecretFindingsToJson(SecretFindings instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'findings': instance.findings.map((e) => e.toJson()).toList(),
    };
