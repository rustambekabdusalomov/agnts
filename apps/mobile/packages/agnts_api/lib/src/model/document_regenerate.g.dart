// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_regenerate.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentRegenerateCWProxy {
  DocumentRegenerate source_(DocumentSourceInput? source_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentRegenerate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentRegenerate(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentRegenerate call({DocumentSourceInput? source_});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentRegenerate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentRegenerate.copyWith.fieldName(...)`
class _$DocumentRegenerateCWProxyImpl implements _$DocumentRegenerateCWProxy {
  const _$DocumentRegenerateCWProxyImpl(this._value);

  final DocumentRegenerate _value;

  @override
  DocumentRegenerate source_(DocumentSourceInput? source_) =>
      this(source_: source_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentRegenerate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentRegenerate(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentRegenerate call({Object? source_ = const $CopyWithPlaceholder()}) {
    return DocumentRegenerate(
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as DocumentSourceInput?,
    );
  }
}

extension $DocumentRegenerateCopyWith on DocumentRegenerate {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentRegenerate.copyWith(...)` or like so:`instanceOfDocumentRegenerate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentRegenerateCWProxy get copyWith =>
      _$DocumentRegenerateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentRegenerate _$DocumentRegenerateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentRegenerate', json, ($checkedConvert) {
      final val = DocumentRegenerate(
        source_: $checkedConvert(
          'source',
          (v) => v == null
              ? null
              : DocumentSourceInput.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$DocumentRegenerateToJson(DocumentRegenerate instance) =>
    <String, dynamic>{'source': ?instance.source_?.toJson()};
