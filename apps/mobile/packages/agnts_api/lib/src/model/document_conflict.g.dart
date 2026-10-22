// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_conflict.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentConflictCWProxy {
  DocumentConflict code(String code);

  DocumentConflict message(String message);

  DocumentConflict current(Document? current);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentConflict(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentConflict(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentConflict call({String code, String message, Document? current});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentConflict.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentConflict.copyWith.fieldName(...)`
class _$DocumentConflictCWProxyImpl implements _$DocumentConflictCWProxy {
  const _$DocumentConflictCWProxyImpl(this._value);

  final DocumentConflict _value;

  @override
  DocumentConflict code(String code) => this(code: code);

  @override
  DocumentConflict message(String message) => this(message: message);

  @override
  DocumentConflict current(Document? current) => this(current: current);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentConflict(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentConflict(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentConflict call({
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? current = const $CopyWithPlaceholder(),
  }) {
    return DocumentConflict(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      current: current == const $CopyWithPlaceholder()
          ? _value.current
          // ignore: cast_nullable_to_non_nullable
          : current as Document?,
    );
  }
}

extension $DocumentConflictCopyWith on DocumentConflict {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentConflict.copyWith(...)` or like so:`instanceOfDocumentConflict.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentConflictCWProxy get copyWith => _$DocumentConflictCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentConflict _$DocumentConflictFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentConflict', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'message']);
      final val = DocumentConflict(
        code: $checkedConvert('code', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        current: $checkedConvert(
          'current',
          (v) =>
              v == null ? null : Document.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DocumentConflictToJson(DocumentConflict instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'current': ?instance.current?.toJson(),
    };
