// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_period.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeliveryPeriodCWProxy {
  DeliveryPeriod opened(int opened);

  DeliveryPeriod merged(int merged);

  DeliveryPeriod closed(int closed);

  DeliveryPeriod mergeMin(Spread mergeMin);

  DeliveryPeriod pushed(int pushed);

  DeliveryPeriod pushedMin(Spread pushedMin);

  DeliveryPeriod mergedTickets(int mergedTickets);

  DeliveryPeriod mergedMin(Spread mergedMin);

  DeliveryPeriod questions(int questions);

  DeliveryPeriod askedTickets(int askedTickets);

  DeliveryPeriod analyzedTickets(int analyzedTickets);

  DeliveryPeriod answerMin(Spread answerMin);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeliveryPeriod(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeliveryPeriod(...).copyWith(id: 12, name: "My name")
  /// ````
  DeliveryPeriod call({
    int opened,
    int merged,
    int closed,
    Spread mergeMin,
    int pushed,
    Spread pushedMin,
    int mergedTickets,
    Spread mergedMin,
    int questions,
    int askedTickets,
    int analyzedTickets,
    Spread answerMin,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeliveryPeriod.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeliveryPeriod.copyWith.fieldName(...)`
class _$DeliveryPeriodCWProxyImpl implements _$DeliveryPeriodCWProxy {
  const _$DeliveryPeriodCWProxyImpl(this._value);

  final DeliveryPeriod _value;

  @override
  DeliveryPeriod opened(int opened) => this(opened: opened);

  @override
  DeliveryPeriod merged(int merged) => this(merged: merged);

  @override
  DeliveryPeriod closed(int closed) => this(closed: closed);

  @override
  DeliveryPeriod mergeMin(Spread mergeMin) => this(mergeMin: mergeMin);

  @override
  DeliveryPeriod pushed(int pushed) => this(pushed: pushed);

  @override
  DeliveryPeriod pushedMin(Spread pushedMin) => this(pushedMin: pushedMin);

  @override
  DeliveryPeriod mergedTickets(int mergedTickets) =>
      this(mergedTickets: mergedTickets);

  @override
  DeliveryPeriod mergedMin(Spread mergedMin) => this(mergedMin: mergedMin);

  @override
  DeliveryPeriod questions(int questions) => this(questions: questions);

  @override
  DeliveryPeriod askedTickets(int askedTickets) =>
      this(askedTickets: askedTickets);

  @override
  DeliveryPeriod analyzedTickets(int analyzedTickets) =>
      this(analyzedTickets: analyzedTickets);

  @override
  DeliveryPeriod answerMin(Spread answerMin) => this(answerMin: answerMin);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeliveryPeriod(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeliveryPeriod(...).copyWith(id: 12, name: "My name")
  /// ````
  DeliveryPeriod call({
    Object? opened = const $CopyWithPlaceholder(),
    Object? merged = const $CopyWithPlaceholder(),
    Object? closed = const $CopyWithPlaceholder(),
    Object? mergeMin = const $CopyWithPlaceholder(),
    Object? pushed = const $CopyWithPlaceholder(),
    Object? pushedMin = const $CopyWithPlaceholder(),
    Object? mergedTickets = const $CopyWithPlaceholder(),
    Object? mergedMin = const $CopyWithPlaceholder(),
    Object? questions = const $CopyWithPlaceholder(),
    Object? askedTickets = const $CopyWithPlaceholder(),
    Object? analyzedTickets = const $CopyWithPlaceholder(),
    Object? answerMin = const $CopyWithPlaceholder(),
  }) {
    return DeliveryPeriod(
      opened: opened == const $CopyWithPlaceholder()
          ? _value.opened
          // ignore: cast_nullable_to_non_nullable
          : opened as int,
      merged: merged == const $CopyWithPlaceholder()
          ? _value.merged
          // ignore: cast_nullable_to_non_nullable
          : merged as int,
      closed: closed == const $CopyWithPlaceholder()
          ? _value.closed
          // ignore: cast_nullable_to_non_nullable
          : closed as int,
      mergeMin: mergeMin == const $CopyWithPlaceholder()
          ? _value.mergeMin
          // ignore: cast_nullable_to_non_nullable
          : mergeMin as Spread,
      pushed: pushed == const $CopyWithPlaceholder()
          ? _value.pushed
          // ignore: cast_nullable_to_non_nullable
          : pushed as int,
      pushedMin: pushedMin == const $CopyWithPlaceholder()
          ? _value.pushedMin
          // ignore: cast_nullable_to_non_nullable
          : pushedMin as Spread,
      mergedTickets: mergedTickets == const $CopyWithPlaceholder()
          ? _value.mergedTickets
          // ignore: cast_nullable_to_non_nullable
          : mergedTickets as int,
      mergedMin: mergedMin == const $CopyWithPlaceholder()
          ? _value.mergedMin
          // ignore: cast_nullable_to_non_nullable
          : mergedMin as Spread,
      questions: questions == const $CopyWithPlaceholder()
          ? _value.questions
          // ignore: cast_nullable_to_non_nullable
          : questions as int,
      askedTickets: askedTickets == const $CopyWithPlaceholder()
          ? _value.askedTickets
          // ignore: cast_nullable_to_non_nullable
          : askedTickets as int,
      analyzedTickets: analyzedTickets == const $CopyWithPlaceholder()
          ? _value.analyzedTickets
          // ignore: cast_nullable_to_non_nullable
          : analyzedTickets as int,
      answerMin: answerMin == const $CopyWithPlaceholder()
          ? _value.answerMin
          // ignore: cast_nullable_to_non_nullable
          : answerMin as Spread,
    );
  }
}

extension $DeliveryPeriodCopyWith on DeliveryPeriod {
  /// Returns a callable class that can be used as follows: `instanceOfDeliveryPeriod.copyWith(...)` or like so:`instanceOfDeliveryPeriod.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeliveryPeriodCWProxy get copyWith => _$DeliveryPeriodCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryPeriod _$DeliveryPeriodFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DeliveryPeriod', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'opened',
      'merged',
      'closed',
      'mergeMin',
      'pushed',
      'pushedMin',
      'mergedTickets',
      'mergedMin',
      'questions',
      'askedTickets',
      'analyzedTickets',
      'answerMin',
    ],
  );
  final val = DeliveryPeriod(
    opened: $checkedConvert('opened', (v) => (v as num).toInt()),
    merged: $checkedConvert('merged', (v) => (v as num).toInt()),
    closed: $checkedConvert('closed', (v) => (v as num).toInt()),
    mergeMin: $checkedConvert(
      'mergeMin',
      (v) => Spread.fromJson(v as Map<String, dynamic>),
    ),
    pushed: $checkedConvert('pushed', (v) => (v as num).toInt()),
    pushedMin: $checkedConvert(
      'pushedMin',
      (v) => Spread.fromJson(v as Map<String, dynamic>),
    ),
    mergedTickets: $checkedConvert('mergedTickets', (v) => (v as num).toInt()),
    mergedMin: $checkedConvert(
      'mergedMin',
      (v) => Spread.fromJson(v as Map<String, dynamic>),
    ),
    questions: $checkedConvert('questions', (v) => (v as num).toInt()),
    askedTickets: $checkedConvert('askedTickets', (v) => (v as num).toInt()),
    analyzedTickets: $checkedConvert(
      'analyzedTickets',
      (v) => (v as num).toInt(),
    ),
    answerMin: $checkedConvert(
      'answerMin',
      (v) => Spread.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DeliveryPeriodToJson(DeliveryPeriod instance) =>
    <String, dynamic>{
      'opened': instance.opened,
      'merged': instance.merged,
      'closed': instance.closed,
      'mergeMin': instance.mergeMin.toJson(),
      'pushed': instance.pushed,
      'pushedMin': instance.pushedMin.toJson(),
      'mergedTickets': instance.mergedTickets,
      'mergedMin': instance.mergedMin.toJson(),
      'questions': instance.questions,
      'askedTickets': instance.askedTickets,
      'analyzedTickets': instance.analyzedTickets,
      'answerMin': instance.answerMin.toJson(),
    };
