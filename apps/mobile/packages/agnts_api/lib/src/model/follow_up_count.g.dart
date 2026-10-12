// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_up_count.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FollowUpCountCWProxy {
  FollowUpCount name(String name);

  FollowUpCount suggested(int suggested);

  FollowUpCount accepted(int accepted);

  FollowUpCount dismissed(int dismissed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FollowUpCount(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FollowUpCount(...).copyWith(id: 12, name: "My name")
  /// ````
  FollowUpCount call({String name, int suggested, int accepted, int dismissed});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFollowUpCount.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFollowUpCount.copyWith.fieldName(...)`
class _$FollowUpCountCWProxyImpl implements _$FollowUpCountCWProxy {
  const _$FollowUpCountCWProxyImpl(this._value);

  final FollowUpCount _value;

  @override
  FollowUpCount name(String name) => this(name: name);

  @override
  FollowUpCount suggested(int suggested) => this(suggested: suggested);

  @override
  FollowUpCount accepted(int accepted) => this(accepted: accepted);

  @override
  FollowUpCount dismissed(int dismissed) => this(dismissed: dismissed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FollowUpCount(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FollowUpCount(...).copyWith(id: 12, name: "My name")
  /// ````
  FollowUpCount call({
    Object? name = const $CopyWithPlaceholder(),
    Object? suggested = const $CopyWithPlaceholder(),
    Object? accepted = const $CopyWithPlaceholder(),
    Object? dismissed = const $CopyWithPlaceholder(),
  }) {
    return FollowUpCount(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      suggested: suggested == const $CopyWithPlaceholder()
          ? _value.suggested
          // ignore: cast_nullable_to_non_nullable
          : suggested as int,
      accepted: accepted == const $CopyWithPlaceholder()
          ? _value.accepted
          // ignore: cast_nullable_to_non_nullable
          : accepted as int,
      dismissed: dismissed == const $CopyWithPlaceholder()
          ? _value.dismissed
          // ignore: cast_nullable_to_non_nullable
          : dismissed as int,
    );
  }
}

extension $FollowUpCountCopyWith on FollowUpCount {
  /// Returns a callable class that can be used as follows: `instanceOfFollowUpCount.copyWith(...)` or like so:`instanceOfFollowUpCount.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FollowUpCountCWProxy get copyWith => _$FollowUpCountCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowUpCount _$FollowUpCountFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FollowUpCount', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['name', 'suggested', 'accepted', 'dismissed'],
      );
      final val = FollowUpCount(
        name: $checkedConvert('name', (v) => v as String),
        suggested: $checkedConvert('suggested', (v) => (v as num).toInt()),
        accepted: $checkedConvert('accepted', (v) => (v as num).toInt()),
        dismissed: $checkedConvert('dismissed', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$FollowUpCountToJson(FollowUpCount instance) =>
    <String, dynamic>{
      'name': instance.name,
      'suggested': instance.suggested,
      'accepted': instance.accepted,
      'dismissed': instance.dismissed,
    };
