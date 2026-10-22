// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secret_findings_findings_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecretFindingsFindingsInnerCWProxy {
  SecretFindingsFindingsInner line(int line);

  SecretFindingsFindingsInner excerpt(String excerpt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecretFindingsFindingsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecretFindingsFindingsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  SecretFindingsFindingsInner call({int line, String excerpt});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecretFindingsFindingsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecretFindingsFindingsInner.copyWith.fieldName(...)`
class _$SecretFindingsFindingsInnerCWProxyImpl
    implements _$SecretFindingsFindingsInnerCWProxy {
  const _$SecretFindingsFindingsInnerCWProxyImpl(this._value);

  final SecretFindingsFindingsInner _value;

  @override
  SecretFindingsFindingsInner line(int line) => this(line: line);

  @override
  SecretFindingsFindingsInner excerpt(String excerpt) => this(excerpt: excerpt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecretFindingsFindingsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecretFindingsFindingsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  SecretFindingsFindingsInner call({
    Object? line = const $CopyWithPlaceholder(),
    Object? excerpt = const $CopyWithPlaceholder(),
  }) {
    return SecretFindingsFindingsInner(
      line: line == const $CopyWithPlaceholder()
          ? _value.line
          // ignore: cast_nullable_to_non_nullable
          : line as int,
      excerpt: excerpt == const $CopyWithPlaceholder()
          ? _value.excerpt
          // ignore: cast_nullable_to_non_nullable
          : excerpt as String,
    );
  }
}

extension $SecretFindingsFindingsInnerCopyWith on SecretFindingsFindingsInner {
  /// Returns a callable class that can be used as follows: `instanceOfSecretFindingsFindingsInner.copyWith(...)` or like so:`instanceOfSecretFindingsFindingsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecretFindingsFindingsInnerCWProxy get copyWith =>
      _$SecretFindingsFindingsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecretFindingsFindingsInner _$SecretFindingsFindingsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SecretFindingsFindingsInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['line', 'excerpt']);
  final val = SecretFindingsFindingsInner(
    line: $checkedConvert('line', (v) => (v as num).toInt()),
    excerpt: $checkedConvert('excerpt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SecretFindingsFindingsInnerToJson(
  SecretFindingsFindingsInner instance,
) => <String, dynamic>{'line': instance.line, 'excerpt': instance.excerpt};
