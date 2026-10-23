// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_presence.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentPresenceCWProxy {
  DocumentPresence viewers(List<DocumentViewer> viewers);

  DocumentPresence commentsStamp(String commentsStamp);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentPresence(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentPresence(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentPresence call({List<DocumentViewer> viewers, String commentsStamp});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentPresence.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentPresence.copyWith.fieldName(...)`
class _$DocumentPresenceCWProxyImpl implements _$DocumentPresenceCWProxy {
  const _$DocumentPresenceCWProxyImpl(this._value);

  final DocumentPresence _value;

  @override
  DocumentPresence viewers(List<DocumentViewer> viewers) =>
      this(viewers: viewers);

  @override
  DocumentPresence commentsStamp(String commentsStamp) =>
      this(commentsStamp: commentsStamp);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentPresence(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentPresence(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentPresence call({
    Object? viewers = const $CopyWithPlaceholder(),
    Object? commentsStamp = const $CopyWithPlaceholder(),
  }) {
    return DocumentPresence(
      viewers: viewers == const $CopyWithPlaceholder()
          ? _value.viewers
          // ignore: cast_nullable_to_non_nullable
          : viewers as List<DocumentViewer>,
      commentsStamp: commentsStamp == const $CopyWithPlaceholder()
          ? _value.commentsStamp
          // ignore: cast_nullable_to_non_nullable
          : commentsStamp as String,
    );
  }
}

extension $DocumentPresenceCopyWith on DocumentPresence {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentPresence.copyWith(...)` or like so:`instanceOfDocumentPresence.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentPresenceCWProxy get copyWith => _$DocumentPresenceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentPresence _$DocumentPresenceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentPresence', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['viewers', 'commentsStamp']);
      final val = DocumentPresence(
        viewers: $checkedConvert(
          'viewers',
          (v) => (v as List<dynamic>)
              .map((e) => DocumentViewer.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        commentsStamp: $checkedConvert('commentsStamp', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$DocumentPresenceToJson(DocumentPresence instance) =>
    <String, dynamic>{
      'viewers': instance.viewers.map((e) => e.toJson()).toList(),
      'commentsStamp': instance.commentsStamp,
    };
