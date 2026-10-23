// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_viewer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentViewerCWProxy {
  DocumentViewer kind(DocumentViewerKindEnum kind);

  DocumentViewer id(int id);

  DocumentViewer name(String name);

  DocumentViewer via(DocumentViewerViaEnum? via);

  DocumentViewer you(bool you);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentViewer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentViewer(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentViewer call({
    DocumentViewerKindEnum kind,
    int id,
    String name,
    DocumentViewerViaEnum? via,
    bool you,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentViewer.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentViewer.copyWith.fieldName(...)`
class _$DocumentViewerCWProxyImpl implements _$DocumentViewerCWProxy {
  const _$DocumentViewerCWProxyImpl(this._value);

  final DocumentViewer _value;

  @override
  DocumentViewer kind(DocumentViewerKindEnum kind) => this(kind: kind);

  @override
  DocumentViewer id(int id) => this(id: id);

  @override
  DocumentViewer name(String name) => this(name: name);

  @override
  DocumentViewer via(DocumentViewerViaEnum? via) => this(via: via);

  @override
  DocumentViewer you(bool you) => this(you: you);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentViewer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentViewer(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentViewer call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? via = const $CopyWithPlaceholder(),
    Object? you = const $CopyWithPlaceholder(),
  }) {
    return DocumentViewer(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as DocumentViewerKindEnum,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      via: via == const $CopyWithPlaceholder()
          ? _value.via
          // ignore: cast_nullable_to_non_nullable
          : via as DocumentViewerViaEnum?,
      you: you == const $CopyWithPlaceholder()
          ? _value.you
          // ignore: cast_nullable_to_non_nullable
          : you as bool,
    );
  }
}

extension $DocumentViewerCopyWith on DocumentViewer {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentViewer.copyWith(...)` or like so:`instanceOfDocumentViewer.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentViewerCWProxy get copyWith => _$DocumentViewerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentViewer _$DocumentViewerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentViewer', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind', 'id', 'name', 'you']);
      final val = DocumentViewer(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$DocumentViewerKindEnumEnumMap, v),
        ),
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        via: $checkedConvert(
          'via',
          (v) => $enumDecodeNullable(_$DocumentViewerViaEnumEnumMap, v),
        ),
        you: $checkedConvert('you', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$DocumentViewerToJson(DocumentViewer instance) =>
    <String, dynamic>{
      'kind': _$DocumentViewerKindEnumEnumMap[instance.kind]!,
      'id': instance.id,
      'name': instance.name,
      'via': ?_$DocumentViewerViaEnumEnumMap[instance.via],
      'you': instance.you,
    };

const _$DocumentViewerKindEnumEnumMap = {
  DocumentViewerKindEnum.member: 'member',
  DocumentViewerKindEnum.guest: 'guest',
};

const _$DocumentViewerViaEnumEnumMap = {
  DocumentViewerViaEnum.name: 'name',
  DocumentViewerViaEnum.google: 'google',
  DocumentViewerViaEnum.account: 'account',
};
