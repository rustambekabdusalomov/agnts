// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_update.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TrackerUpdateCWProxy {
  TrackerUpdate title(String title);

  TrackerUpdate description(String description);

  TrackerUpdate at(DateTime at);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TrackerUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TrackerUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  TrackerUpdate call({String title, String description, DateTime at});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTrackerUpdate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTrackerUpdate.copyWith.fieldName(...)`
class _$TrackerUpdateCWProxyImpl implements _$TrackerUpdateCWProxy {
  const _$TrackerUpdateCWProxyImpl(this._value);

  final TrackerUpdate _value;

  @override
  TrackerUpdate title(String title) => this(title: title);

  @override
  TrackerUpdate description(String description) =>
      this(description: description);

  @override
  TrackerUpdate at(DateTime at) => this(at: at);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TrackerUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TrackerUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  TrackerUpdate call({
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? at = const $CopyWithPlaceholder(),
  }) {
    return TrackerUpdate(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      at: at == const $CopyWithPlaceholder()
          ? _value.at
          // ignore: cast_nullable_to_non_nullable
          : at as DateTime,
    );
  }
}

extension $TrackerUpdateCopyWith on TrackerUpdate {
  /// Returns a callable class that can be used as follows: `instanceOfTrackerUpdate.copyWith(...)` or like so:`instanceOfTrackerUpdate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TrackerUpdateCWProxy get copyWith => _$TrackerUpdateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackerUpdate _$TrackerUpdateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TrackerUpdate', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['title', 'description', 'at']);
      final val = TrackerUpdate(
        title: $checkedConvert('title', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
      );
      return val;
    });

Map<String, dynamic> _$TrackerUpdateToJson(TrackerUpdate instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'at': instance.at.toIso8601String(),
    };
