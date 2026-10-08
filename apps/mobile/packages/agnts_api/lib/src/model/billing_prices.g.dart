// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_prices.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BillingPricesCWProxy {
  BillingPrices workspaceUsd(double workspaceUsd);

  BillingPrices slotUsd(double slotUsd);

  BillingPrices memberUsd(double memberUsd);

  BillingPrices creditUsd(double creditUsd);

  BillingPrices workspaceUzs(int workspaceUzs);

  BillingPrices slotUzs(int slotUzs);

  BillingPrices memberUzs(int memberUzs);

  BillingPrices creditUzs(int creditUzs);

  BillingPrices includedMembers(int includedMembers);

  BillingPrices markup(num markup);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BillingPrices(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BillingPrices(...).copyWith(id: 12, name: "My name")
  /// ````
  BillingPrices call({
    double workspaceUsd,
    double slotUsd,
    double memberUsd,
    double creditUsd,
    int workspaceUzs,
    int slotUzs,
    int memberUzs,
    int creditUzs,
    int includedMembers,
    num markup,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBillingPrices.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBillingPrices.copyWith.fieldName(...)`
class _$BillingPricesCWProxyImpl implements _$BillingPricesCWProxy {
  const _$BillingPricesCWProxyImpl(this._value);

  final BillingPrices _value;

  @override
  BillingPrices workspaceUsd(double workspaceUsd) =>
      this(workspaceUsd: workspaceUsd);

  @override
  BillingPrices slotUsd(double slotUsd) => this(slotUsd: slotUsd);

  @override
  BillingPrices memberUsd(double memberUsd) => this(memberUsd: memberUsd);

  @override
  BillingPrices creditUsd(double creditUsd) => this(creditUsd: creditUsd);

  @override
  BillingPrices workspaceUzs(int workspaceUzs) =>
      this(workspaceUzs: workspaceUzs);

  @override
  BillingPrices slotUzs(int slotUzs) => this(slotUzs: slotUzs);

  @override
  BillingPrices memberUzs(int memberUzs) => this(memberUzs: memberUzs);

  @override
  BillingPrices creditUzs(int creditUzs) => this(creditUzs: creditUzs);

  @override
  BillingPrices includedMembers(int includedMembers) =>
      this(includedMembers: includedMembers);

  @override
  BillingPrices markup(num markup) => this(markup: markup);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BillingPrices(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BillingPrices(...).copyWith(id: 12, name: "My name")
  /// ````
  BillingPrices call({
    Object? workspaceUsd = const $CopyWithPlaceholder(),
    Object? slotUsd = const $CopyWithPlaceholder(),
    Object? memberUsd = const $CopyWithPlaceholder(),
    Object? creditUsd = const $CopyWithPlaceholder(),
    Object? workspaceUzs = const $CopyWithPlaceholder(),
    Object? slotUzs = const $CopyWithPlaceholder(),
    Object? memberUzs = const $CopyWithPlaceholder(),
    Object? creditUzs = const $CopyWithPlaceholder(),
    Object? includedMembers = const $CopyWithPlaceholder(),
    Object? markup = const $CopyWithPlaceholder(),
  }) {
    return BillingPrices(
      workspaceUsd: workspaceUsd == const $CopyWithPlaceholder()
          ? _value.workspaceUsd
          // ignore: cast_nullable_to_non_nullable
          : workspaceUsd as double,
      slotUsd: slotUsd == const $CopyWithPlaceholder()
          ? _value.slotUsd
          // ignore: cast_nullable_to_non_nullable
          : slotUsd as double,
      memberUsd: memberUsd == const $CopyWithPlaceholder()
          ? _value.memberUsd
          // ignore: cast_nullable_to_non_nullable
          : memberUsd as double,
      creditUsd: creditUsd == const $CopyWithPlaceholder()
          ? _value.creditUsd
          // ignore: cast_nullable_to_non_nullable
          : creditUsd as double,
      workspaceUzs: workspaceUzs == const $CopyWithPlaceholder()
          ? _value.workspaceUzs
          // ignore: cast_nullable_to_non_nullable
          : workspaceUzs as int,
      slotUzs: slotUzs == const $CopyWithPlaceholder()
          ? _value.slotUzs
          // ignore: cast_nullable_to_non_nullable
          : slotUzs as int,
      memberUzs: memberUzs == const $CopyWithPlaceholder()
          ? _value.memberUzs
          // ignore: cast_nullable_to_non_nullable
          : memberUzs as int,
      creditUzs: creditUzs == const $CopyWithPlaceholder()
          ? _value.creditUzs
          // ignore: cast_nullable_to_non_nullable
          : creditUzs as int,
      includedMembers: includedMembers == const $CopyWithPlaceholder()
          ? _value.includedMembers
          // ignore: cast_nullable_to_non_nullable
          : includedMembers as int,
      markup: markup == const $CopyWithPlaceholder()
          ? _value.markup
          // ignore: cast_nullable_to_non_nullable
          : markup as num,
    );
  }
}

extension $BillingPricesCopyWith on BillingPrices {
  /// Returns a callable class that can be used as follows: `instanceOfBillingPrices.copyWith(...)` or like so:`instanceOfBillingPrices.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BillingPricesCWProxy get copyWith => _$BillingPricesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillingPrices _$BillingPricesFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BillingPrices', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'workspaceUsd',
      'slotUsd',
      'memberUsd',
      'creditUsd',
      'workspaceUzs',
      'slotUzs',
      'memberUzs',
      'creditUzs',
      'includedMembers',
      'markup',
    ],
  );
  final val = BillingPrices(
    workspaceUsd: $checkedConvert('workspaceUsd', (v) => (v as num).toDouble()),
    slotUsd: $checkedConvert('slotUsd', (v) => (v as num).toDouble()),
    memberUsd: $checkedConvert('memberUsd', (v) => (v as num).toDouble()),
    creditUsd: $checkedConvert('creditUsd', (v) => (v as num).toDouble()),
    workspaceUzs: $checkedConvert('workspaceUzs', (v) => (v as num).toInt()),
    slotUzs: $checkedConvert('slotUzs', (v) => (v as num).toInt()),
    memberUzs: $checkedConvert('memberUzs', (v) => (v as num).toInt()),
    creditUzs: $checkedConvert('creditUzs', (v) => (v as num).toInt()),
    includedMembers: $checkedConvert(
      'includedMembers',
      (v) => (v as num).toInt(),
    ),
    markup: $checkedConvert('markup', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$BillingPricesToJson(BillingPrices instance) =>
    <String, dynamic>{
      'workspaceUsd': instance.workspaceUsd,
      'slotUsd': instance.slotUsd,
      'memberUsd': instance.memberUsd,
      'creditUsd': instance.creditUsd,
      'workspaceUzs': instance.workspaceUzs,
      'slotUzs': instance.slotUzs,
      'memberUzs': instance.memberUzs,
      'creditUzs': instance.creditUzs,
      'includedMembers': instance.includedMembers,
      'markup': instance.markup,
    };
