// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_grant.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentGrantCWProxy {
  DocumentGrant userId(int userId);

  DocumentGrant username(String? username);

  DocumentGrant level(DocumentGrantLevelEnum level);

  DocumentGrant createdAt(DateTime? createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentGrant(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentGrant(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentGrant call({
    int userId,
    String? username,
    DocumentGrantLevelEnum level,
    DateTime? createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentGrant.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentGrant.copyWith.fieldName(...)`
class _$DocumentGrantCWProxyImpl implements _$DocumentGrantCWProxy {
  const _$DocumentGrantCWProxyImpl(this._value);

  final DocumentGrant _value;

  @override
  DocumentGrant userId(int userId) => this(userId: userId);

  @override
  DocumentGrant username(String? username) => this(username: username);

  @override
  DocumentGrant level(DocumentGrantLevelEnum level) => this(level: level);

  @override
  DocumentGrant createdAt(DateTime? createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentGrant(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentGrant(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentGrant call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? level = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return DocumentGrant(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int,
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String?,
      level: level == const $CopyWithPlaceholder()
          ? _value.level
          // ignore: cast_nullable_to_non_nullable
          : level as DocumentGrantLevelEnum,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime?,
    );
  }
}

extension $DocumentGrantCopyWith on DocumentGrant {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentGrant.copyWith(...)` or like so:`instanceOfDocumentGrant.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentGrantCWProxy get copyWith => _$DocumentGrantCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentGrant _$DocumentGrantFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentGrant', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['userId', 'level']);
      final val = DocumentGrant(
        userId: $checkedConvert('userId', (v) => (v as num).toInt()),
        username: $checkedConvert('username', (v) => v as String?),
        level: $checkedConvert(
          'level',
          (v) => $enumDecode(_$DocumentGrantLevelEnumEnumMap, v),
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DocumentGrantToJson(DocumentGrant instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': ?instance.username,
      'level': _$DocumentGrantLevelEnumEnumMap[instance.level]!,
      'createdAt': ?instance.createdAt?.toIso8601String(),
    };

const _$DocumentGrantLevelEnumEnumMap = {
  DocumentGrantLevelEnum.view: 'view',
  DocumentGrantLevelEnum.edit: 'edit',
};
