// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_check.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EditCheckCWProxy {
  EditCheck name(String name);

  EditCheck globs(List<String> globs);

  EditCheck cmd(String cmd);

  EditCheck every(int? every);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EditCheck(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EditCheck(...).copyWith(id: 12, name: "My name")
  /// ````
  EditCheck call({String name, List<String> globs, String cmd, int? every});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEditCheck.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEditCheck.copyWith.fieldName(...)`
class _$EditCheckCWProxyImpl implements _$EditCheckCWProxy {
  const _$EditCheckCWProxyImpl(this._value);

  final EditCheck _value;

  @override
  EditCheck name(String name) => this(name: name);

  @override
  EditCheck globs(List<String> globs) => this(globs: globs);

  @override
  EditCheck cmd(String cmd) => this(cmd: cmd);

  @override
  EditCheck every(int? every) => this(every: every);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EditCheck(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EditCheck(...).copyWith(id: 12, name: "My name")
  /// ````
  EditCheck call({
    Object? name = const $CopyWithPlaceholder(),
    Object? globs = const $CopyWithPlaceholder(),
    Object? cmd = const $CopyWithPlaceholder(),
    Object? every = const $CopyWithPlaceholder(),
  }) {
    return EditCheck(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      globs: globs == const $CopyWithPlaceholder()
          ? _value.globs
          // ignore: cast_nullable_to_non_nullable
          : globs as List<String>,
      cmd: cmd == const $CopyWithPlaceholder()
          ? _value.cmd
          // ignore: cast_nullable_to_non_nullable
          : cmd as String,
      every: every == const $CopyWithPlaceholder()
          ? _value.every
          // ignore: cast_nullable_to_non_nullable
          : every as int?,
    );
  }
}

extension $EditCheckCopyWith on EditCheck {
  /// Returns a callable class that can be used as follows: `instanceOfEditCheck.copyWith(...)` or like so:`instanceOfEditCheck.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EditCheckCWProxy get copyWith => _$EditCheckCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditCheck _$EditCheckFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EditCheck', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'globs', 'cmd']);
      final val = EditCheck(
        name: $checkedConvert('name', (v) => v as String),
        globs: $checkedConvert(
          'globs',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        cmd: $checkedConvert('cmd', (v) => v as String),
        every: $checkedConvert('every', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$EditCheckToJson(EditCheck instance) => <String, dynamic>{
  'name': instance.name,
  'globs': instance.globs,
  'cmd': instance.cmd,
  'every': ?instance.every,
};
