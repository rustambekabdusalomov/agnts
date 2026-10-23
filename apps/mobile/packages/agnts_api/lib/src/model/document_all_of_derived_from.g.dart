// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_all_of_derived_from.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentAllOfDerivedFromCWProxy {
  DocumentAllOfDerivedFrom id(int id);

  DocumentAllOfDerivedFrom title(String title);

  DocumentAllOfDerivedFrom version(int version);

  DocumentAllOfDerivedFrom currentVersion(int currentVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentAllOfDerivedFrom(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentAllOfDerivedFrom(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentAllOfDerivedFrom call({
    int id,
    String title,
    int version,
    int currentVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentAllOfDerivedFrom.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentAllOfDerivedFrom.copyWith.fieldName(...)`
class _$DocumentAllOfDerivedFromCWProxyImpl
    implements _$DocumentAllOfDerivedFromCWProxy {
  const _$DocumentAllOfDerivedFromCWProxyImpl(this._value);

  final DocumentAllOfDerivedFrom _value;

  @override
  DocumentAllOfDerivedFrom id(int id) => this(id: id);

  @override
  DocumentAllOfDerivedFrom title(String title) => this(title: title);

  @override
  DocumentAllOfDerivedFrom version(int version) => this(version: version);

  @override
  DocumentAllOfDerivedFrom currentVersion(int currentVersion) =>
      this(currentVersion: currentVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentAllOfDerivedFrom(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentAllOfDerivedFrom(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentAllOfDerivedFrom call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? currentVersion = const $CopyWithPlaceholder(),
  }) {
    return DocumentAllOfDerivedFrom(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      currentVersion: currentVersion == const $CopyWithPlaceholder()
          ? _value.currentVersion
          // ignore: cast_nullable_to_non_nullable
          : currentVersion as int,
    );
  }
}

extension $DocumentAllOfDerivedFromCopyWith on DocumentAllOfDerivedFrom {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentAllOfDerivedFrom.copyWith(...)` or like so:`instanceOfDocumentAllOfDerivedFrom.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentAllOfDerivedFromCWProxy get copyWith =>
      _$DocumentAllOfDerivedFromCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentAllOfDerivedFrom _$DocumentAllOfDerivedFromFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentAllOfDerivedFrom', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'title', 'version', 'currentVersion'],
  );
  final val = DocumentAllOfDerivedFrom(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    title: $checkedConvert('title', (v) => v as String),
    version: $checkedConvert('version', (v) => (v as num).toInt()),
    currentVersion: $checkedConvert(
      'currentVersion',
      (v) => (v as num).toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$DocumentAllOfDerivedFromToJson(
  DocumentAllOfDerivedFrom instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'version': instance.version,
  'currentVersion': instance.currentVersion,
};
