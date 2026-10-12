// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_network_ca.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PrivateNetworkCaCWProxy {
  PrivateNetworkCa subjects(List<String> subjects);

  PrivateNetworkCa notAfter(DateTime notAfter);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrivateNetworkCa(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrivateNetworkCa(...).copyWith(id: 12, name: "My name")
  /// ````
  PrivateNetworkCa call({List<String> subjects, DateTime notAfter});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPrivateNetworkCa.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPrivateNetworkCa.copyWith.fieldName(...)`
class _$PrivateNetworkCaCWProxyImpl implements _$PrivateNetworkCaCWProxy {
  const _$PrivateNetworkCaCWProxyImpl(this._value);

  final PrivateNetworkCa _value;

  @override
  PrivateNetworkCa subjects(List<String> subjects) => this(subjects: subjects);

  @override
  PrivateNetworkCa notAfter(DateTime notAfter) => this(notAfter: notAfter);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrivateNetworkCa(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrivateNetworkCa(...).copyWith(id: 12, name: "My name")
  /// ````
  PrivateNetworkCa call({
    Object? subjects = const $CopyWithPlaceholder(),
    Object? notAfter = const $CopyWithPlaceholder(),
  }) {
    return PrivateNetworkCa(
      subjects: subjects == const $CopyWithPlaceholder()
          ? _value.subjects
          // ignore: cast_nullable_to_non_nullable
          : subjects as List<String>,
      notAfter: notAfter == const $CopyWithPlaceholder()
          ? _value.notAfter
          // ignore: cast_nullable_to_non_nullable
          : notAfter as DateTime,
    );
  }
}

extension $PrivateNetworkCaCopyWith on PrivateNetworkCa {
  /// Returns a callable class that can be used as follows: `instanceOfPrivateNetworkCa.copyWith(...)` or like so:`instanceOfPrivateNetworkCa.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PrivateNetworkCaCWProxy get copyWith => _$PrivateNetworkCaCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateNetworkCa _$PrivateNetworkCaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PrivateNetworkCa', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['subjects', 'notAfter']);
      final val = PrivateNetworkCa(
        subjects: $checkedConvert(
          'subjects',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        notAfter: $checkedConvert(
          'notAfter',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PrivateNetworkCaToJson(PrivateNetworkCa instance) =>
    <String, dynamic>{
      'subjects': instance.subjects,
      'notAfter': instance.notAfter.toIso8601String(),
    };
