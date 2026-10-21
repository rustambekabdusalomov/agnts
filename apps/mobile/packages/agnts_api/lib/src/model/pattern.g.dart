// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PatternCWProxy {
  Pattern file(String file);

  Pattern kind(PatternKindEnum kind);

  Pattern like(String like);

  Pattern layer(String? layer);

  Pattern why(String? why);

  Pattern place(String? place);

  Pattern precedent(bool? precedent);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Pattern(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Pattern(...).copyWith(id: 12, name: "My name")
  /// ````
  Pattern call({
    String file,
    PatternKindEnum kind,
    String like,
    String? layer,
    String? why,
    String? place,
    bool? precedent,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPattern.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPattern.copyWith.fieldName(...)`
class _$PatternCWProxyImpl implements _$PatternCWProxy {
  const _$PatternCWProxyImpl(this._value);

  final Pattern _value;

  @override
  Pattern file(String file) => this(file: file);

  @override
  Pattern kind(PatternKindEnum kind) => this(kind: kind);

  @override
  Pattern like(String like) => this(like: like);

  @override
  Pattern layer(String? layer) => this(layer: layer);

  @override
  Pattern why(String? why) => this(why: why);

  @override
  Pattern place(String? place) => this(place: place);

  @override
  Pattern precedent(bool? precedent) => this(precedent: precedent);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Pattern(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Pattern(...).copyWith(id: 12, name: "My name")
  /// ````
  Pattern call({
    Object? file = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? like = const $CopyWithPlaceholder(),
    Object? layer = const $CopyWithPlaceholder(),
    Object? why = const $CopyWithPlaceholder(),
    Object? place = const $CopyWithPlaceholder(),
    Object? precedent = const $CopyWithPlaceholder(),
  }) {
    return Pattern(
      file: file == const $CopyWithPlaceholder()
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as PatternKindEnum,
      like: like == const $CopyWithPlaceholder()
          ? _value.like
          // ignore: cast_nullable_to_non_nullable
          : like as String,
      layer: layer == const $CopyWithPlaceholder()
          ? _value.layer
          // ignore: cast_nullable_to_non_nullable
          : layer as String?,
      why: why == const $CopyWithPlaceholder()
          ? _value.why
          // ignore: cast_nullable_to_non_nullable
          : why as String?,
      place: place == const $CopyWithPlaceholder()
          ? _value.place
          // ignore: cast_nullable_to_non_nullable
          : place as String?,
      precedent: precedent == const $CopyWithPlaceholder()
          ? _value.precedent
          // ignore: cast_nullable_to_non_nullable
          : precedent as bool?,
    );
  }
}

extension $PatternCopyWith on Pattern {
  /// Returns a callable class that can be used as follows: `instanceOfPattern.copyWith(...)` or like so:`instanceOfPattern.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PatternCWProxy get copyWith => _$PatternCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pattern _$PatternFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Pattern', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['file', 'kind', 'like']);
      final val = Pattern(
        file: $checkedConvert('file', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$PatternKindEnumEnumMap, v),
        ),
        like: $checkedConvert('like', (v) => v as String),
        layer: $checkedConvert('layer', (v) => v as String?),
        why: $checkedConvert('why', (v) => v as String?),
        place: $checkedConvert('place', (v) => v as String?),
        precedent: $checkedConvert('precedent', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$PatternToJson(Pattern instance) => <String, dynamic>{
  'file': instance.file,
  'kind': _$PatternKindEnumEnumMap[instance.kind]!,
  'like': instance.like,
  'layer': ?instance.layer,
  'why': ?instance.why,
  'place': ?instance.place,
  'precedent': ?instance.precedent,
};

const _$PatternKindEnumEnumMap = {
  PatternKindEnum.copy: 'copy',
  PatternKindEnum.adapt: 'adapt',
  PatternKindEnum.new_: 'new',
};
