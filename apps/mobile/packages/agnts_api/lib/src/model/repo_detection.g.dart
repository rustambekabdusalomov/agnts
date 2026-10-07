// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_detection.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoDetectionCWProxy {
  RepoDetection toolchains(List<Toolchain> toolchains);

  RepoDetection buildCmd(String buildCmd);

  RepoDetection lintCmd(String lintCmd);

  RepoDetection testCmd(String testCmd);

  RepoDetection notes(List<String> notes);

  RepoDetection stack(String stack);

  RepoDetection source_(RepoDetectionSource_Enum source_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoDetection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoDetection(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoDetection call({
    List<Toolchain> toolchains,
    String buildCmd,
    String lintCmd,
    String testCmd,
    List<String> notes,
    String stack,
    RepoDetectionSource_Enum source_,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoDetection.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoDetection.copyWith.fieldName(...)`
class _$RepoDetectionCWProxyImpl implements _$RepoDetectionCWProxy {
  const _$RepoDetectionCWProxyImpl(this._value);

  final RepoDetection _value;

  @override
  RepoDetection toolchains(List<Toolchain> toolchains) =>
      this(toolchains: toolchains);

  @override
  RepoDetection buildCmd(String buildCmd) => this(buildCmd: buildCmd);

  @override
  RepoDetection lintCmd(String lintCmd) => this(lintCmd: lintCmd);

  @override
  RepoDetection testCmd(String testCmd) => this(testCmd: testCmd);

  @override
  RepoDetection notes(List<String> notes) => this(notes: notes);

  @override
  RepoDetection stack(String stack) => this(stack: stack);

  @override
  RepoDetection source_(RepoDetectionSource_Enum source_) =>
      this(source_: source_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoDetection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoDetection(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoDetection call({
    Object? toolchains = const $CopyWithPlaceholder(),
    Object? buildCmd = const $CopyWithPlaceholder(),
    Object? lintCmd = const $CopyWithPlaceholder(),
    Object? testCmd = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? stack = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
  }) {
    return RepoDetection(
      toolchains: toolchains == const $CopyWithPlaceholder()
          ? _value.toolchains
          // ignore: cast_nullable_to_non_nullable
          : toolchains as List<Toolchain>,
      buildCmd: buildCmd == const $CopyWithPlaceholder()
          ? _value.buildCmd
          // ignore: cast_nullable_to_non_nullable
          : buildCmd as String,
      lintCmd: lintCmd == const $CopyWithPlaceholder()
          ? _value.lintCmd
          // ignore: cast_nullable_to_non_nullable
          : lintCmd as String,
      testCmd: testCmd == const $CopyWithPlaceholder()
          ? _value.testCmd
          // ignore: cast_nullable_to_non_nullable
          : testCmd as String,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as List<String>,
      stack: stack == const $CopyWithPlaceholder()
          ? _value.stack
          // ignore: cast_nullable_to_non_nullable
          : stack as String,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as RepoDetectionSource_Enum,
    );
  }
}

extension $RepoDetectionCopyWith on RepoDetection {
  /// Returns a callable class that can be used as follows: `instanceOfRepoDetection.copyWith(...)` or like so:`instanceOfRepoDetection.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoDetectionCWProxy get copyWith => _$RepoDetectionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoDetection _$RepoDetectionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoDetection', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'toolchains',
          'buildCmd',
          'lintCmd',
          'testCmd',
          'notes',
          'stack',
          'source',
        ],
      );
      final val = RepoDetection(
        toolchains: $checkedConvert(
          'toolchains',
          (v) => (v as List<dynamic>)
              .map((e) => Toolchain.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        buildCmd: $checkedConvert('buildCmd', (v) => v as String),
        lintCmd: $checkedConvert('lintCmd', (v) => v as String),
        testCmd: $checkedConvert('testCmd', (v) => v as String),
        notes: $checkedConvert(
          'notes',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        stack: $checkedConvert('stack', (v) => v as String),
        source_: $checkedConvert(
          'source',
          (v) => $enumDecode(_$RepoDetectionSource_EnumEnumMap, v),
        ),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$RepoDetectionToJson(RepoDetection instance) =>
    <String, dynamic>{
      'toolchains': instance.toolchains.map((e) => e.toJson()).toList(),
      'buildCmd': instance.buildCmd,
      'lintCmd': instance.lintCmd,
      'testCmd': instance.testCmd,
      'notes': instance.notes,
      'stack': instance.stack,
      'source': _$RepoDetectionSource_EnumEnumMap[instance.source_]!,
    };

const _$RepoDetectionSource_EnumEnumMap = {
  RepoDetectionSource_Enum.files: 'files',
  RepoDetectionSource_Enum.claude: 'claude',
};
