// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'egress_status.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EgressStatusCWProxy {
  EgressStatus reachable(bool reachable);

  EgressStatus error(String? error);

  EgressStatus upstream(EgressUpstream? upstream);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EgressStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EgressStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  EgressStatus call({bool reachable, String? error, EgressUpstream? upstream});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEgressStatus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEgressStatus.copyWith.fieldName(...)`
class _$EgressStatusCWProxyImpl implements _$EgressStatusCWProxy {
  const _$EgressStatusCWProxyImpl(this._value);

  final EgressStatus _value;

  @override
  EgressStatus reachable(bool reachable) => this(reachable: reachable);

  @override
  EgressStatus error(String? error) => this(error: error);

  @override
  EgressStatus upstream(EgressUpstream? upstream) => this(upstream: upstream);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EgressStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EgressStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  EgressStatus call({
    Object? reachable = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? upstream = const $CopyWithPlaceholder(),
  }) {
    return EgressStatus(
      reachable: reachable == const $CopyWithPlaceholder()
          ? _value.reachable
          // ignore: cast_nullable_to_non_nullable
          : reachable as bool,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      upstream: upstream == const $CopyWithPlaceholder()
          ? _value.upstream
          // ignore: cast_nullable_to_non_nullable
          : upstream as EgressUpstream?,
    );
  }
}

extension $EgressStatusCopyWith on EgressStatus {
  /// Returns a callable class that can be used as follows: `instanceOfEgressStatus.copyWith(...)` or like so:`instanceOfEgressStatus.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EgressStatusCWProxy get copyWith => _$EgressStatusCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EgressStatus _$EgressStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EgressStatus', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['reachable']);
      final val = EgressStatus(
        reachable: $checkedConvert('reachable', (v) => v as bool),
        error: $checkedConvert('error', (v) => v as String?),
        upstream: $checkedConvert(
          'upstream',
          (v) => v == null
              ? null
              : EgressUpstream.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EgressStatusToJson(EgressStatus instance) =>
    <String, dynamic>{
      'reachable': instance.reachable,
      'error': ?instance.error,
      'upstream': ?instance.upstream?.toJson(),
    };
