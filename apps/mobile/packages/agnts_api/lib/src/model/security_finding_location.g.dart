// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_finding_location.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SecurityFindingLocationCWProxy {
  SecurityFindingLocation file(String? file);

  SecurityFindingLocation line(int? line);

  SecurityFindingLocation url(String? url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecurityFindingLocation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecurityFindingLocation(...).copyWith(id: 12, name: "My name")
  /// ````
  SecurityFindingLocation call({String? file, int? line, String? url});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSecurityFindingLocation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSecurityFindingLocation.copyWith.fieldName(...)`
class _$SecurityFindingLocationCWProxyImpl
    implements _$SecurityFindingLocationCWProxy {
  const _$SecurityFindingLocationCWProxyImpl(this._value);

  final SecurityFindingLocation _value;

  @override
  SecurityFindingLocation file(String? file) => this(file: file);

  @override
  SecurityFindingLocation line(int? line) => this(line: line);

  @override
  SecurityFindingLocation url(String? url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SecurityFindingLocation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SecurityFindingLocation(...).copyWith(id: 12, name: "My name")
  /// ````
  SecurityFindingLocation call({
    Object? file = const $CopyWithPlaceholder(),
    Object? line = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return SecurityFindingLocation(
      file: file == const $CopyWithPlaceholder()
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as String?,
      line: line == const $CopyWithPlaceholder()
          ? _value.line
          // ignore: cast_nullable_to_non_nullable
          : line as int?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
    );
  }
}

extension $SecurityFindingLocationCopyWith on SecurityFindingLocation {
  /// Returns a callable class that can be used as follows: `instanceOfSecurityFindingLocation.copyWith(...)` or like so:`instanceOfSecurityFindingLocation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SecurityFindingLocationCWProxy get copyWith =>
      _$SecurityFindingLocationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityFindingLocation _$SecurityFindingLocationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SecurityFindingLocation', json, ($checkedConvert) {
  final val = SecurityFindingLocation(
    file: $checkedConvert('file', (v) => v as String?),
    line: $checkedConvert('line', (v) => (v as num?)?.toInt()),
    url: $checkedConvert('url', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$SecurityFindingLocationToJson(
  SecurityFindingLocation instance,
) => <String, dynamic>{
  'file': ?instance.file,
  'line': ?instance.line,
  'url': ?instance.url,
};
