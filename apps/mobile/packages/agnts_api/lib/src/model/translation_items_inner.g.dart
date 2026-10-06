// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_items_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TranslationItemsInnerCWProxy {
  TranslationItemsInner source_(String source_);

  TranslationItemsInner text(String text);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TranslationItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TranslationItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  TranslationItemsInner call({String source_, String text});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTranslationItemsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTranslationItemsInner.copyWith.fieldName(...)`
class _$TranslationItemsInnerCWProxyImpl
    implements _$TranslationItemsInnerCWProxy {
  const _$TranslationItemsInnerCWProxyImpl(this._value);

  final TranslationItemsInner _value;

  @override
  TranslationItemsInner source_(String source_) => this(source_: source_);

  @override
  TranslationItemsInner text(String text) => this(text: text);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TranslationItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TranslationItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  TranslationItemsInner call({
    Object? source_ = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
  }) {
    return TranslationItemsInner(
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as String,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
    );
  }
}

extension $TranslationItemsInnerCopyWith on TranslationItemsInner {
  /// Returns a callable class that can be used as follows: `instanceOfTranslationItemsInner.copyWith(...)` or like so:`instanceOfTranslationItemsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TranslationItemsInnerCWProxy get copyWith =>
      _$TranslationItemsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationItemsInner _$TranslationItemsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TranslationItemsInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['source', 'text']);
  final val = TranslationItemsInner(
    source_: $checkedConvert('source', (v) => v as String),
    text: $checkedConvert('text', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$TranslationItemsInnerToJson(
  TranslationItemsInner instance,
) => <String, dynamic>{'source': instance.source_, 'text': instance.text};
