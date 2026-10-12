// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'starter_pack.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StarterPackCWProxy {
  StarterPack pack(String pack);

  StarterPack name(String name);

  StarterPack rules(int rules);

  StarterPack offered(bool offered);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StarterPack(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StarterPack(...).copyWith(id: 12, name: "My name")
  /// ````
  StarterPack call({String pack, String name, int rules, bool offered});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStarterPack.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStarterPack.copyWith.fieldName(...)`
class _$StarterPackCWProxyImpl implements _$StarterPackCWProxy {
  const _$StarterPackCWProxyImpl(this._value);

  final StarterPack _value;

  @override
  StarterPack pack(String pack) => this(pack: pack);

  @override
  StarterPack name(String name) => this(name: name);

  @override
  StarterPack rules(int rules) => this(rules: rules);

  @override
  StarterPack offered(bool offered) => this(offered: offered);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StarterPack(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StarterPack(...).copyWith(id: 12, name: "My name")
  /// ````
  StarterPack call({
    Object? pack = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? rules = const $CopyWithPlaceholder(),
    Object? offered = const $CopyWithPlaceholder(),
  }) {
    return StarterPack(
      pack: pack == const $CopyWithPlaceholder()
          ? _value.pack
          // ignore: cast_nullable_to_non_nullable
          : pack as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      rules: rules == const $CopyWithPlaceholder()
          ? _value.rules
          // ignore: cast_nullable_to_non_nullable
          : rules as int,
      offered: offered == const $CopyWithPlaceholder()
          ? _value.offered
          // ignore: cast_nullable_to_non_nullable
          : offered as bool,
    );
  }
}

extension $StarterPackCopyWith on StarterPack {
  /// Returns a callable class that can be used as follows: `instanceOfStarterPack.copyWith(...)` or like so:`instanceOfStarterPack.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StarterPackCWProxy get copyWith => _$StarterPackCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StarterPack _$StarterPackFromJson(Map<String, dynamic> json) => $checkedCreate(
  'StarterPack',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['pack', 'name', 'rules', 'offered']);
    final val = StarterPack(
      pack: $checkedConvert('pack', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      rules: $checkedConvert('rules', (v) => (v as num).toInt()),
      offered: $checkedConvert('offered', (v) => v as bool),
    );
    return val;
  },
);

Map<String, dynamic> _$StarterPackToJson(StarterPack instance) =>
    <String, dynamic>{
      'pack': instance.pack,
      'name': instance.name,
      'rules': instance.rules,
      'offered': instance.offered,
    };
