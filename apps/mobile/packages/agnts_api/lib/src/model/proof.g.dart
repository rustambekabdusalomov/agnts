// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proof.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProofCWProxy {
  Proof status(ProofStatusEnum status);

  Proof base_(String? base_);

  Proof why(String? why);

  Proof tests(List<ProofTest> tests);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Proof(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Proof(...).copyWith(id: 12, name: "My name")
  /// ````
  Proof call({
    ProofStatusEnum status,
    String? base_,
    String? why,
    List<ProofTest> tests,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProof.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProof.copyWith.fieldName(...)`
class _$ProofCWProxyImpl implements _$ProofCWProxy {
  const _$ProofCWProxyImpl(this._value);

  final Proof _value;

  @override
  Proof status(ProofStatusEnum status) => this(status: status);

  @override
  Proof base_(String? base_) => this(base_: base_);

  @override
  Proof why(String? why) => this(why: why);

  @override
  Proof tests(List<ProofTest> tests) => this(tests: tests);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Proof(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Proof(...).copyWith(id: 12, name: "My name")
  /// ````
  Proof call({
    Object? status = const $CopyWithPlaceholder(),
    Object? base_ = const $CopyWithPlaceholder(),
    Object? why = const $CopyWithPlaceholder(),
    Object? tests = const $CopyWithPlaceholder(),
  }) {
    return Proof(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ProofStatusEnum,
      base_: base_ == const $CopyWithPlaceholder()
          ? _value.base_
          // ignore: cast_nullable_to_non_nullable
          : base_ as String?,
      why: why == const $CopyWithPlaceholder()
          ? _value.why
          // ignore: cast_nullable_to_non_nullable
          : why as String?,
      tests: tests == const $CopyWithPlaceholder()
          ? _value.tests
          // ignore: cast_nullable_to_non_nullable
          : tests as List<ProofTest>,
    );
  }
}

extension $ProofCopyWith on Proof {
  /// Returns a callable class that can be used as follows: `instanceOfProof.copyWith(...)` or like so:`instanceOfProof.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProofCWProxy get copyWith => _$ProofCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Proof _$ProofFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Proof', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status', 'tests']);
      final val = Proof(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$ProofStatusEnumEnumMap, v),
        ),
        base_: $checkedConvert('base', (v) => v as String?),
        why: $checkedConvert('why', (v) => v as String?),
        tests: $checkedConvert(
          'tests',
          (v) => (v as List<dynamic>)
              .map((e) => ProofTest.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'base_': 'base'});

Map<String, dynamic> _$ProofToJson(Proof instance) => <String, dynamic>{
  'status': _$ProofStatusEnumEnumMap[instance.status]!,
  'base': ?instance.base_,
  'why': ?instance.why,
  'tests': instance.tests.map((e) => e.toJson()).toList(),
};

const _$ProofStatusEnumEnumMap = {
  ProofStatusEnum.proven: 'proven',
  ProofStatusEnum.notReproduced: 'not_reproduced',
  ProofStatusEnum.stillFailing: 'still_failing',
  ProofStatusEnum.inconclusive: 'inconclusive',
  ProofStatusEnum.noTest: 'no_test',
  ProofStatusEnum.error: 'error',
};
