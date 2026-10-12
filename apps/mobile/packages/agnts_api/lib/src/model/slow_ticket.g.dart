// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slow_ticket.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SlowTicketCWProxy {
  SlowTicket key(String key);

  SlowTicket title(String title);

  SlowTicket cycleMin(num cycleMin);

  SlowTicket agntsMin(num agntsMin);

  SlowTicket answersMin(num answersMin);

  SlowTicket reviewMin(num reviewMin);

  SlowTicket queueMin(num queueMin);

  SlowTicket merged(bool merged);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SlowTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SlowTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  SlowTicket call({
    String key,
    String title,
    num cycleMin,
    num agntsMin,
    num answersMin,
    num reviewMin,
    num queueMin,
    bool merged,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSlowTicket.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSlowTicket.copyWith.fieldName(...)`
class _$SlowTicketCWProxyImpl implements _$SlowTicketCWProxy {
  const _$SlowTicketCWProxyImpl(this._value);

  final SlowTicket _value;

  @override
  SlowTicket key(String key) => this(key: key);

  @override
  SlowTicket title(String title) => this(title: title);

  @override
  SlowTicket cycleMin(num cycleMin) => this(cycleMin: cycleMin);

  @override
  SlowTicket agntsMin(num agntsMin) => this(agntsMin: agntsMin);

  @override
  SlowTicket answersMin(num answersMin) => this(answersMin: answersMin);

  @override
  SlowTicket reviewMin(num reviewMin) => this(reviewMin: reviewMin);

  @override
  SlowTicket queueMin(num queueMin) => this(queueMin: queueMin);

  @override
  SlowTicket merged(bool merged) => this(merged: merged);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SlowTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SlowTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  SlowTicket call({
    Object? key = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? cycleMin = const $CopyWithPlaceholder(),
    Object? agntsMin = const $CopyWithPlaceholder(),
    Object? answersMin = const $CopyWithPlaceholder(),
    Object? reviewMin = const $CopyWithPlaceholder(),
    Object? queueMin = const $CopyWithPlaceholder(),
    Object? merged = const $CopyWithPlaceholder(),
  }) {
    return SlowTicket(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      cycleMin: cycleMin == const $CopyWithPlaceholder()
          ? _value.cycleMin
          // ignore: cast_nullable_to_non_nullable
          : cycleMin as num,
      agntsMin: agntsMin == const $CopyWithPlaceholder()
          ? _value.agntsMin
          // ignore: cast_nullable_to_non_nullable
          : agntsMin as num,
      answersMin: answersMin == const $CopyWithPlaceholder()
          ? _value.answersMin
          // ignore: cast_nullable_to_non_nullable
          : answersMin as num,
      reviewMin: reviewMin == const $CopyWithPlaceholder()
          ? _value.reviewMin
          // ignore: cast_nullable_to_non_nullable
          : reviewMin as num,
      queueMin: queueMin == const $CopyWithPlaceholder()
          ? _value.queueMin
          // ignore: cast_nullable_to_non_nullable
          : queueMin as num,
      merged: merged == const $CopyWithPlaceholder()
          ? _value.merged
          // ignore: cast_nullable_to_non_nullable
          : merged as bool,
    );
  }
}

extension $SlowTicketCopyWith on SlowTicket {
  /// Returns a callable class that can be used as follows: `instanceOfSlowTicket.copyWith(...)` or like so:`instanceOfSlowTicket.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SlowTicketCWProxy get copyWith => _$SlowTicketCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlowTicket _$SlowTicketFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SlowTicket', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'key',
          'title',
          'cycleMin',
          'agntsMin',
          'answersMin',
          'reviewMin',
          'queueMin',
          'merged',
        ],
      );
      final val = SlowTicket(
        key: $checkedConvert('key', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        cycleMin: $checkedConvert('cycleMin', (v) => v as num),
        agntsMin: $checkedConvert('agntsMin', (v) => v as num),
        answersMin: $checkedConvert('answersMin', (v) => v as num),
        reviewMin: $checkedConvert('reviewMin', (v) => v as num),
        queueMin: $checkedConvert('queueMin', (v) => v as num),
        merged: $checkedConvert('merged', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$SlowTicketToJson(SlowTicket instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'cycleMin': instance.cycleMin,
      'agntsMin': instance.agntsMin,
      'answersMin': instance.answersMin,
      'reviewMin': instance.reviewMin,
      'queueMin': instance.queueMin,
      'merged': instance.merged,
    };
