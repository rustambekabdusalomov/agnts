// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_notes.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ShipNotesCWProxy {
  ShipNotes migrations(String? migrations);

  ShipNotes compatibility(String? compatibility);

  ShipNotes rollout(String? rollout);

  ShipNotes rollback(String? rollback);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShipNotes(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShipNotes(...).copyWith(id: 12, name: "My name")
  /// ````
  ShipNotes call({
    String? migrations,
    String? compatibility,
    String? rollout,
    String? rollback,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfShipNotes.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfShipNotes.copyWith.fieldName(...)`
class _$ShipNotesCWProxyImpl implements _$ShipNotesCWProxy {
  const _$ShipNotesCWProxyImpl(this._value);

  final ShipNotes _value;

  @override
  ShipNotes migrations(String? migrations) => this(migrations: migrations);

  @override
  ShipNotes compatibility(String? compatibility) =>
      this(compatibility: compatibility);

  @override
  ShipNotes rollout(String? rollout) => this(rollout: rollout);

  @override
  ShipNotes rollback(String? rollback) => this(rollback: rollback);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShipNotes(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShipNotes(...).copyWith(id: 12, name: "My name")
  /// ````
  ShipNotes call({
    Object? migrations = const $CopyWithPlaceholder(),
    Object? compatibility = const $CopyWithPlaceholder(),
    Object? rollout = const $CopyWithPlaceholder(),
    Object? rollback = const $CopyWithPlaceholder(),
  }) {
    return ShipNotes(
      migrations: migrations == const $CopyWithPlaceholder()
          ? _value.migrations
          // ignore: cast_nullable_to_non_nullable
          : migrations as String?,
      compatibility: compatibility == const $CopyWithPlaceholder()
          ? _value.compatibility
          // ignore: cast_nullable_to_non_nullable
          : compatibility as String?,
      rollout: rollout == const $CopyWithPlaceholder()
          ? _value.rollout
          // ignore: cast_nullable_to_non_nullable
          : rollout as String?,
      rollback: rollback == const $CopyWithPlaceholder()
          ? _value.rollback
          // ignore: cast_nullable_to_non_nullable
          : rollback as String?,
    );
  }
}

extension $ShipNotesCopyWith on ShipNotes {
  /// Returns a callable class that can be used as follows: `instanceOfShipNotes.copyWith(...)` or like so:`instanceOfShipNotes.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ShipNotesCWProxy get copyWith => _$ShipNotesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShipNotes _$ShipNotesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ShipNotes', json, ($checkedConvert) {
      final val = ShipNotes(
        migrations: $checkedConvert('migrations', (v) => v as String?),
        compatibility: $checkedConvert('compatibility', (v) => v as String?),
        rollout: $checkedConvert('rollout', (v) => v as String?),
        rollback: $checkedConvert('rollback', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ShipNotesToJson(ShipNotes instance) => <String, dynamic>{
  'migrations': ?instance.migrations,
  'compatibility': ?instance.compatibility,
  'rollout': ?instance.rollout,
  'rollback': ?instance.rollback,
};
