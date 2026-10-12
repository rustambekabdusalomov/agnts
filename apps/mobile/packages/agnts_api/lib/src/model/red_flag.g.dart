// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'red_flag.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RedFlagCWProxy {
  RedFlag kind(RedFlagKindEnum kind);

  RedFlag path(String path);

  RedFlag line(int? line);

  RedFlag text(String text);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RedFlag(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RedFlag(...).copyWith(id: 12, name: "My name")
  /// ````
  RedFlag call({RedFlagKindEnum kind, String path, int? line, String text});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRedFlag.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRedFlag.copyWith.fieldName(...)`
class _$RedFlagCWProxyImpl implements _$RedFlagCWProxy {
  const _$RedFlagCWProxyImpl(this._value);

  final RedFlag _value;

  @override
  RedFlag kind(RedFlagKindEnum kind) => this(kind: kind);

  @override
  RedFlag path(String path) => this(path: path);

  @override
  RedFlag line(int? line) => this(line: line);

  @override
  RedFlag text(String text) => this(text: text);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RedFlag(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RedFlag(...).copyWith(id: 12, name: "My name")
  /// ````
  RedFlag call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? line = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
  }) {
    return RedFlag(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as RedFlagKindEnum,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      line: line == const $CopyWithPlaceholder()
          ? _value.line
          // ignore: cast_nullable_to_non_nullable
          : line as int?,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
    );
  }
}

extension $RedFlagCopyWith on RedFlag {
  /// Returns a callable class that can be used as follows: `instanceOfRedFlag.copyWith(...)` or like so:`instanceOfRedFlag.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RedFlagCWProxy get copyWith => _$RedFlagCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedFlag _$RedFlagFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RedFlag', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind', 'path', 'text']);
      final val = RedFlag(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$RedFlagKindEnumEnumMap, v),
        ),
        path: $checkedConvert('path', (v) => v as String),
        line: $checkedConvert('line', (v) => (v as num?)?.toInt()),
        text: $checkedConvert('text', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RedFlagToJson(RedFlag instance) => <String, dynamic>{
  'kind': _$RedFlagKindEnumEnumMap[instance.kind]!,
  'path': instance.path,
  'line': ?instance.line,
  'text': instance.text,
};

const _$RedFlagKindEnumEnumMap = {
  RedFlagKindEnum.secret: 'secret',
  RedFlagKindEnum.envFile: 'env_file',
  RedFlagKindEnum.skippedTest: 'skipped_test',
  RedFlagKindEnum.removedAssertion: 'removed_assertion',
  RedFlagKindEnum.deletedTest: 'deleted_test',
  RedFlagKindEnum.silencedLint: 'silenced_lint',
  RedFlagKindEnum.checkConfig: 'check_config',
  RedFlagKindEnum.swallowedError: 'swallowed_error',
  RedFlagKindEnum.ruleViolation: 'rule_violation',
  RedFlagKindEnum.debugLeftover: 'debug_leftover',
  RedFlagKindEnum.todo: 'todo',
  RedFlagKindEnum.newDependency: 'new_dependency',
};
