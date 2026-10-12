// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proof_test.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProofTestCWProxy {
  ProofTest file(String file);

  ProofTest name(String name);

  ProofTest command(String command);

  ProofTest status(String status);

  ProofTest before(ProofRun before);

  ProofTest after(ProofRun after);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProofTest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProofTest(...).copyWith(id: 12, name: "My name")
  /// ````
  ProofTest call({
    String file,
    String name,
    String command,
    String status,
    ProofRun before,
    ProofRun after,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProofTest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProofTest.copyWith.fieldName(...)`
class _$ProofTestCWProxyImpl implements _$ProofTestCWProxy {
  const _$ProofTestCWProxyImpl(this._value);

  final ProofTest _value;

  @override
  ProofTest file(String file) => this(file: file);

  @override
  ProofTest name(String name) => this(name: name);

  @override
  ProofTest command(String command) => this(command: command);

  @override
  ProofTest status(String status) => this(status: status);

  @override
  ProofTest before(ProofRun before) => this(before: before);

  @override
  ProofTest after(ProofRun after) => this(after: after);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProofTest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProofTest(...).copyWith(id: 12, name: "My name")
  /// ````
  ProofTest call({
    Object? file = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? command = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? before = const $CopyWithPlaceholder(),
    Object? after = const $CopyWithPlaceholder(),
  }) {
    return ProofTest(
      file: file == const $CopyWithPlaceholder()
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      command: command == const $CopyWithPlaceholder()
          ? _value.command
          // ignore: cast_nullable_to_non_nullable
          : command as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      before: before == const $CopyWithPlaceholder()
          ? _value.before
          // ignore: cast_nullable_to_non_nullable
          : before as ProofRun,
      after: after == const $CopyWithPlaceholder()
          ? _value.after
          // ignore: cast_nullable_to_non_nullable
          : after as ProofRun,
    );
  }
}

extension $ProofTestCopyWith on ProofTest {
  /// Returns a callable class that can be used as follows: `instanceOfProofTest.copyWith(...)` or like so:`instanceOfProofTest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProofTestCWProxy get copyWith => _$ProofTestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProofTest _$ProofTestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProofTest', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'file',
          'name',
          'command',
          'status',
          'before',
          'after',
        ],
      );
      final val = ProofTest(
        file: $checkedConvert('file', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        command: $checkedConvert('command', (v) => v as String),
        status: $checkedConvert('status', (v) => v as String),
        before: $checkedConvert(
          'before',
          (v) => ProofRun.fromJson(v as Map<String, dynamic>),
        ),
        after: $checkedConvert(
          'after',
          (v) => ProofRun.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ProofTestToJson(ProofTest instance) => <String, dynamic>{
  'file': instance.file,
  'name': instance.name,
  'command': instance.command,
  'status': instance.status,
  'before': instance.before.toJson(),
  'after': instance.after.toJson(),
};
