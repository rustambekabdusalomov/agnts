// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_share_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentShareInputCWProxy {
  DocumentShareInput type(DocumentShareInputTypeEnum type);

  DocumentShareInput workspaceAccess(
    DocumentShareInputWorkspaceAccessEnum workspaceAccess,
  );

  DocumentShareInput grants(List<DocumentShareInputGrantsInner> grants);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentShareInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentShareInput(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentShareInput call({
    DocumentShareInputTypeEnum type,
    DocumentShareInputWorkspaceAccessEnum workspaceAccess,
    List<DocumentShareInputGrantsInner> grants,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentShareInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentShareInput.copyWith.fieldName(...)`
class _$DocumentShareInputCWProxyImpl implements _$DocumentShareInputCWProxy {
  const _$DocumentShareInputCWProxyImpl(this._value);

  final DocumentShareInput _value;

  @override
  DocumentShareInput type(DocumentShareInputTypeEnum type) => this(type: type);

  @override
  DocumentShareInput workspaceAccess(
    DocumentShareInputWorkspaceAccessEnum workspaceAccess,
  ) => this(workspaceAccess: workspaceAccess);

  @override
  DocumentShareInput grants(List<DocumentShareInputGrantsInner> grants) =>
      this(grants: grants);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentShareInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentShareInput(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentShareInput call({
    Object? type = const $CopyWithPlaceholder(),
    Object? workspaceAccess = const $CopyWithPlaceholder(),
    Object? grants = const $CopyWithPlaceholder(),
  }) {
    return DocumentShareInput(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as DocumentShareInputTypeEnum,
      workspaceAccess: workspaceAccess == const $CopyWithPlaceholder()
          ? _value.workspaceAccess
          // ignore: cast_nullable_to_non_nullable
          : workspaceAccess as DocumentShareInputWorkspaceAccessEnum,
      grants: grants == const $CopyWithPlaceholder()
          ? _value.grants
          // ignore: cast_nullable_to_non_nullable
          : grants as List<DocumentShareInputGrantsInner>,
    );
  }
}

extension $DocumentShareInputCopyWith on DocumentShareInput {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentShareInput.copyWith(...)` or like so:`instanceOfDocumentShareInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentShareInputCWProxy get copyWith =>
      _$DocumentShareInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentShareInput _$DocumentShareInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentShareInput', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['type', 'workspaceAccess', 'grants']);
  final val = DocumentShareInput(
    type: $checkedConvert(
      'type',
      (v) => $enumDecode(_$DocumentShareInputTypeEnumEnumMap, v),
    ),
    workspaceAccess: $checkedConvert(
      'workspaceAccess',
      (v) => $enumDecode(_$DocumentShareInputWorkspaceAccessEnumEnumMap, v),
    ),
    grants: $checkedConvert(
      'grants',
      (v) => (v as List<dynamic>)
          .map(
            (e) => DocumentShareInputGrantsInner.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$DocumentShareInputToJson(
  DocumentShareInput instance,
) => <String, dynamic>{
  'type': _$DocumentShareInputTypeEnumEnumMap[instance.type]!,
  'workspaceAccess':
      _$DocumentShareInputWorkspaceAccessEnumEnumMap[instance.workspaceAccess]!,
  'grants': instance.grants.map((e) => e.toJson()).toList(),
};

const _$DocumentShareInputTypeEnumEnumMap = {
  DocumentShareInputTypeEnum.private: 'private',
  DocumentShareInputTypeEnum.public: 'public',
};

const _$DocumentShareInputWorkspaceAccessEnumEnumMap = {
  DocumentShareInputWorkspaceAccessEnum.none: 'none',
  DocumentShareInputWorkspaceAccessEnum.view: 'view',
  DocumentShareInputWorkspaceAccessEnum.edit: 'edit',
};
