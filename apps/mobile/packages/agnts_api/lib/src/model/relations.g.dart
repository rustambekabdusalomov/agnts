// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relations.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RelationsCWProxy {
  Relations items(List<Relation> items);

  Relations blockedBy(List<Blocker> blockedBy);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Relations(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Relations(...).copyWith(id: 12, name: "My name")
  /// ````
  Relations call({List<Relation> items, List<Blocker> blockedBy});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRelations.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRelations.copyWith.fieldName(...)`
class _$RelationsCWProxyImpl implements _$RelationsCWProxy {
  const _$RelationsCWProxyImpl(this._value);

  final Relations _value;

  @override
  Relations items(List<Relation> items) => this(items: items);

  @override
  Relations blockedBy(List<Blocker> blockedBy) => this(blockedBy: blockedBy);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Relations(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Relations(...).copyWith(id: 12, name: "My name")
  /// ````
  Relations call({
    Object? items = const $CopyWithPlaceholder(),
    Object? blockedBy = const $CopyWithPlaceholder(),
  }) {
    return Relations(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<Relation>,
      blockedBy: blockedBy == const $CopyWithPlaceholder()
          ? _value.blockedBy
          // ignore: cast_nullable_to_non_nullable
          : blockedBy as List<Blocker>,
    );
  }
}

extension $RelationsCopyWith on Relations {
  /// Returns a callable class that can be used as follows: `instanceOfRelations.copyWith(...)` or like so:`instanceOfRelations.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RelationsCWProxy get copyWith => _$RelationsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Relations _$RelationsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Relations', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items', 'blockedBy']);
      final val = Relations(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => Relation.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        blockedBy: $checkedConvert(
          'blockedBy',
          (v) => (v as List<dynamic>)
              .map((e) => Blocker.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RelationsToJson(Relations instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'blockedBy': instance.blockedBy.map((e) => e.toJson()).toList(),
};
