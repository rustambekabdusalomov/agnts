// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_follow_ups.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AcceptFollowUpsCWProxy {
  AcceptFollowUps items(List<AcceptFollowUp> items);

  AcceptFollowUps start(bool? start);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptFollowUps(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptFollowUps(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptFollowUps call({List<AcceptFollowUp> items, bool? start});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAcceptFollowUps.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAcceptFollowUps.copyWith.fieldName(...)`
class _$AcceptFollowUpsCWProxyImpl implements _$AcceptFollowUpsCWProxy {
  const _$AcceptFollowUpsCWProxyImpl(this._value);

  final AcceptFollowUps _value;

  @override
  AcceptFollowUps items(List<AcceptFollowUp> items) => this(items: items);

  @override
  AcceptFollowUps start(bool? start) => this(start: start);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcceptFollowUps(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcceptFollowUps(...).copyWith(id: 12, name: "My name")
  /// ````
  AcceptFollowUps call({
    Object? items = const $CopyWithPlaceholder(),
    Object? start = const $CopyWithPlaceholder(),
  }) {
    return AcceptFollowUps(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<AcceptFollowUp>,
      start: start == const $CopyWithPlaceholder()
          ? _value.start
          // ignore: cast_nullable_to_non_nullable
          : start as bool?,
    );
  }
}

extension $AcceptFollowUpsCopyWith on AcceptFollowUps {
  /// Returns a callable class that can be used as follows: `instanceOfAcceptFollowUps.copyWith(...)` or like so:`instanceOfAcceptFollowUps.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AcceptFollowUpsCWProxy get copyWith => _$AcceptFollowUpsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptFollowUps _$AcceptFollowUpsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AcceptFollowUps', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items']);
      final val = AcceptFollowUps(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => AcceptFollowUp.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        start: $checkedConvert('start', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$AcceptFollowUpsToJson(AcceptFollowUps instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'start': ?instance.start,
    };
