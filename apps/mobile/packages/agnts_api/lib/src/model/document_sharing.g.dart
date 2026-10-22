// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_sharing.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentSharingCWProxy {
  DocumentSharing type(DocumentSharingTypeEnum type);

  DocumentSharing publicUrl(String? publicUrl);

  DocumentSharing workspaceAccess(
    DocumentSharingWorkspaceAccessEnum workspaceAccess,
  );

  DocumentSharing ownerId(int ownerId);

  DocumentSharing grants(List<DocumentGrant> grants);

  DocumentSharing publicAllowed(bool publicAllowed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentSharing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentSharing(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentSharing call({
    DocumentSharingTypeEnum type,
    String? publicUrl,
    DocumentSharingWorkspaceAccessEnum workspaceAccess,
    int ownerId,
    List<DocumentGrant> grants,
    bool publicAllowed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentSharing.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentSharing.copyWith.fieldName(...)`
class _$DocumentSharingCWProxyImpl implements _$DocumentSharingCWProxy {
  const _$DocumentSharingCWProxyImpl(this._value);

  final DocumentSharing _value;

  @override
  DocumentSharing type(DocumentSharingTypeEnum type) => this(type: type);

  @override
  DocumentSharing publicUrl(String? publicUrl) => this(publicUrl: publicUrl);

  @override
  DocumentSharing workspaceAccess(
    DocumentSharingWorkspaceAccessEnum workspaceAccess,
  ) => this(workspaceAccess: workspaceAccess);

  @override
  DocumentSharing ownerId(int ownerId) => this(ownerId: ownerId);

  @override
  DocumentSharing grants(List<DocumentGrant> grants) => this(grants: grants);

  @override
  DocumentSharing publicAllowed(bool publicAllowed) =>
      this(publicAllowed: publicAllowed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentSharing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentSharing(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentSharing call({
    Object? type = const $CopyWithPlaceholder(),
    Object? publicUrl = const $CopyWithPlaceholder(),
    Object? workspaceAccess = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? grants = const $CopyWithPlaceholder(),
    Object? publicAllowed = const $CopyWithPlaceholder(),
  }) {
    return DocumentSharing(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as DocumentSharingTypeEnum,
      publicUrl: publicUrl == const $CopyWithPlaceholder()
          ? _value.publicUrl
          // ignore: cast_nullable_to_non_nullable
          : publicUrl as String?,
      workspaceAccess: workspaceAccess == const $CopyWithPlaceholder()
          ? _value.workspaceAccess
          // ignore: cast_nullable_to_non_nullable
          : workspaceAccess as DocumentSharingWorkspaceAccessEnum,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as int,
      grants: grants == const $CopyWithPlaceholder()
          ? _value.grants
          // ignore: cast_nullable_to_non_nullable
          : grants as List<DocumentGrant>,
      publicAllowed: publicAllowed == const $CopyWithPlaceholder()
          ? _value.publicAllowed
          // ignore: cast_nullable_to_non_nullable
          : publicAllowed as bool,
    );
  }
}

extension $DocumentSharingCopyWith on DocumentSharing {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentSharing.copyWith(...)` or like so:`instanceOfDocumentSharing.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentSharingCWProxy get copyWith => _$DocumentSharingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentSharing _$DocumentSharingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentSharing', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'type',
          'workspaceAccess',
          'ownerId',
          'grants',
          'publicAllowed',
        ],
      );
      final val = DocumentSharing(
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$DocumentSharingTypeEnumEnumMap, v),
        ),
        publicUrl: $checkedConvert('publicUrl', (v) => v as String?),
        workspaceAccess: $checkedConvert(
          'workspaceAccess',
          (v) => $enumDecode(_$DocumentSharingWorkspaceAccessEnumEnumMap, v),
        ),
        ownerId: $checkedConvert('ownerId', (v) => (v as num).toInt()),
        grants: $checkedConvert(
          'grants',
          (v) => (v as List<dynamic>)
              .map((e) => DocumentGrant.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        publicAllowed: $checkedConvert('publicAllowed', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$DocumentSharingToJson(
  DocumentSharing instance,
) => <String, dynamic>{
  'type': _$DocumentSharingTypeEnumEnumMap[instance.type]!,
  'publicUrl': ?instance.publicUrl,
  'workspaceAccess':
      _$DocumentSharingWorkspaceAccessEnumEnumMap[instance.workspaceAccess]!,
  'ownerId': instance.ownerId,
  'grants': instance.grants.map((e) => e.toJson()).toList(),
  'publicAllowed': instance.publicAllowed,
};

const _$DocumentSharingTypeEnumEnumMap = {
  DocumentSharingTypeEnum.private: 'private',
  DocumentSharingTypeEnum.public: 'public',
};

const _$DocumentSharingWorkspaceAccessEnumEnumMap = {
  DocumentSharingWorkspaceAccessEnum.none: 'none',
  DocumentSharingWorkspaceAccessEnum.view: 'view',
  DocumentSharingWorkspaceAccessEnum.edit: 'edit',
};
