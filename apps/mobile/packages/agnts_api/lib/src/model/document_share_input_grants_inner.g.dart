// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_share_input_grants_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentShareInputGrantsInnerCWProxy {
  DocumentShareInputGrantsInner userId(int userId);

  DocumentShareInputGrantsInner level(
    DocumentShareInputGrantsInnerLevelEnum level,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentShareInputGrantsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentShareInputGrantsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentShareInputGrantsInner call({
    int userId,
    DocumentShareInputGrantsInnerLevelEnum level,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentShareInputGrantsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentShareInputGrantsInner.copyWith.fieldName(...)`
class _$DocumentShareInputGrantsInnerCWProxyImpl
    implements _$DocumentShareInputGrantsInnerCWProxy {
  const _$DocumentShareInputGrantsInnerCWProxyImpl(this._value);

  final DocumentShareInputGrantsInner _value;

  @override
  DocumentShareInputGrantsInner userId(int userId) => this(userId: userId);

  @override
  DocumentShareInputGrantsInner level(
    DocumentShareInputGrantsInnerLevelEnum level,
  ) => this(level: level);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentShareInputGrantsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentShareInputGrantsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentShareInputGrantsInner call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? level = const $CopyWithPlaceholder(),
  }) {
    return DocumentShareInputGrantsInner(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int,
      level: level == const $CopyWithPlaceholder()
          ? _value.level
          // ignore: cast_nullable_to_non_nullable
          : level as DocumentShareInputGrantsInnerLevelEnum,
    );
  }
}

extension $DocumentShareInputGrantsInnerCopyWith
    on DocumentShareInputGrantsInner {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentShareInputGrantsInner.copyWith(...)` or like so:`instanceOfDocumentShareInputGrantsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentShareInputGrantsInnerCWProxy get copyWith =>
      _$DocumentShareInputGrantsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentShareInputGrantsInner _$DocumentShareInputGrantsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentShareInputGrantsInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['userId', 'level']);
  final val = DocumentShareInputGrantsInner(
    userId: $checkedConvert('userId', (v) => (v as num).toInt()),
    level: $checkedConvert(
      'level',
      (v) => $enumDecode(_$DocumentShareInputGrantsInnerLevelEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$DocumentShareInputGrantsInnerToJson(
  DocumentShareInputGrantsInner instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'level': _$DocumentShareInputGrantsInnerLevelEnumEnumMap[instance.level]!,
};

const _$DocumentShareInputGrantsInnerLevelEnumEnumMap = {
  DocumentShareInputGrantsInnerLevelEnum.view: 'view',
  DocumentShareInputGrantsInnerLevelEnum.edit: 'edit',
};
