// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreviewInputCWProxy {
  PreviewInput compare(bool? compare);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreviewInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreviewInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PreviewInput call({bool? compare});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreviewInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreviewInput.copyWith.fieldName(...)`
class _$PreviewInputCWProxyImpl implements _$PreviewInputCWProxy {
  const _$PreviewInputCWProxyImpl(this._value);

  final PreviewInput _value;

  @override
  PreviewInput compare(bool? compare) => this(compare: compare);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreviewInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreviewInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PreviewInput call({Object? compare = const $CopyWithPlaceholder()}) {
    return PreviewInput(
      compare: compare == const $CopyWithPlaceholder()
          ? _value.compare
          // ignore: cast_nullable_to_non_nullable
          : compare as bool?,
    );
  }
}

extension $PreviewInputCopyWith on PreviewInput {
  /// Returns a callable class that can be used as follows: `instanceOfPreviewInput.copyWith(...)` or like so:`instanceOfPreviewInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreviewInputCWProxy get copyWith => _$PreviewInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreviewInput _$PreviewInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PreviewInput', json, ($checkedConvert) {
      final val = PreviewInput(
        compare: $checkedConvert('compare', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$PreviewInputToJson(PreviewInput instance) =>
    <String, dynamic>{'compare': ?instance.compare};
