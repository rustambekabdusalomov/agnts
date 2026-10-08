// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BillingCWProxy {
  Billing plan(String plan);

  Billing slots(int slots);

  Billing maxSlots(int maxSlots);

  Billing memberLimit(int memberLimit);

  Billing members(int members);

  Billing creditsBalance(int creditsBalance);

  Billing trialEndsAt(DateTime? trialEndsAt);

  Billing monthlyUzs(int? monthlyUzs);

  Billing ledger(List<LedgerEntry> ledger);

  Billing prices(BillingPrices prices);

  Billing paymentsEnabled(bool paymentsEnabled);

  Billing selfHosted(bool? selfHosted);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Billing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Billing(...).copyWith(id: 12, name: "My name")
  /// ````
  Billing call({
    String plan,
    int slots,
    int maxSlots,
    int memberLimit,
    int members,
    int creditsBalance,
    DateTime? trialEndsAt,
    int? monthlyUzs,
    List<LedgerEntry> ledger,
    BillingPrices prices,
    bool paymentsEnabled,
    bool? selfHosted,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBilling.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBilling.copyWith.fieldName(...)`
class _$BillingCWProxyImpl implements _$BillingCWProxy {
  const _$BillingCWProxyImpl(this._value);

  final Billing _value;

  @override
  Billing plan(String plan) => this(plan: plan);

  @override
  Billing slots(int slots) => this(slots: slots);

  @override
  Billing maxSlots(int maxSlots) => this(maxSlots: maxSlots);

  @override
  Billing memberLimit(int memberLimit) => this(memberLimit: memberLimit);

  @override
  Billing members(int members) => this(members: members);

  @override
  Billing creditsBalance(int creditsBalance) =>
      this(creditsBalance: creditsBalance);

  @override
  Billing trialEndsAt(DateTime? trialEndsAt) => this(trialEndsAt: trialEndsAt);

  @override
  Billing monthlyUzs(int? monthlyUzs) => this(monthlyUzs: monthlyUzs);

  @override
  Billing ledger(List<LedgerEntry> ledger) => this(ledger: ledger);

  @override
  Billing prices(BillingPrices prices) => this(prices: prices);

  @override
  Billing paymentsEnabled(bool paymentsEnabled) =>
      this(paymentsEnabled: paymentsEnabled);

  @override
  Billing selfHosted(bool? selfHosted) => this(selfHosted: selfHosted);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Billing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Billing(...).copyWith(id: 12, name: "My name")
  /// ````
  Billing call({
    Object? plan = const $CopyWithPlaceholder(),
    Object? slots = const $CopyWithPlaceholder(),
    Object? maxSlots = const $CopyWithPlaceholder(),
    Object? memberLimit = const $CopyWithPlaceholder(),
    Object? members = const $CopyWithPlaceholder(),
    Object? creditsBalance = const $CopyWithPlaceholder(),
    Object? trialEndsAt = const $CopyWithPlaceholder(),
    Object? monthlyUzs = const $CopyWithPlaceholder(),
    Object? ledger = const $CopyWithPlaceholder(),
    Object? prices = const $CopyWithPlaceholder(),
    Object? paymentsEnabled = const $CopyWithPlaceholder(),
    Object? selfHosted = const $CopyWithPlaceholder(),
  }) {
    return Billing(
      plan: plan == const $CopyWithPlaceholder()
          ? _value.plan
          // ignore: cast_nullable_to_non_nullable
          : plan as String,
      slots: slots == const $CopyWithPlaceholder()
          ? _value.slots
          // ignore: cast_nullable_to_non_nullable
          : slots as int,
      maxSlots: maxSlots == const $CopyWithPlaceholder()
          ? _value.maxSlots
          // ignore: cast_nullable_to_non_nullable
          : maxSlots as int,
      memberLimit: memberLimit == const $CopyWithPlaceholder()
          ? _value.memberLimit
          // ignore: cast_nullable_to_non_nullable
          : memberLimit as int,
      members: members == const $CopyWithPlaceholder()
          ? _value.members
          // ignore: cast_nullable_to_non_nullable
          : members as int,
      creditsBalance: creditsBalance == const $CopyWithPlaceholder()
          ? _value.creditsBalance
          // ignore: cast_nullable_to_non_nullable
          : creditsBalance as int,
      trialEndsAt: trialEndsAt == const $CopyWithPlaceholder()
          ? _value.trialEndsAt
          // ignore: cast_nullable_to_non_nullable
          : trialEndsAt as DateTime?,
      monthlyUzs: monthlyUzs == const $CopyWithPlaceholder()
          ? _value.monthlyUzs
          // ignore: cast_nullable_to_non_nullable
          : monthlyUzs as int?,
      ledger: ledger == const $CopyWithPlaceholder()
          ? _value.ledger
          // ignore: cast_nullable_to_non_nullable
          : ledger as List<LedgerEntry>,
      prices: prices == const $CopyWithPlaceholder()
          ? _value.prices
          // ignore: cast_nullable_to_non_nullable
          : prices as BillingPrices,
      paymentsEnabled: paymentsEnabled == const $CopyWithPlaceholder()
          ? _value.paymentsEnabled
          // ignore: cast_nullable_to_non_nullable
          : paymentsEnabled as bool,
      selfHosted: selfHosted == const $CopyWithPlaceholder()
          ? _value.selfHosted
          // ignore: cast_nullable_to_non_nullable
          : selfHosted as bool?,
    );
  }
}

extension $BillingCopyWith on Billing {
  /// Returns a callable class that can be used as follows: `instanceOfBilling.copyWith(...)` or like so:`instanceOfBilling.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BillingCWProxy get copyWith => _$BillingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Billing _$BillingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Billing', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'plan',
          'slots',
          'maxSlots',
          'memberLimit',
          'members',
          'creditsBalance',
          'ledger',
          'prices',
          'paymentsEnabled',
        ],
      );
      final val = Billing(
        plan: $checkedConvert('plan', (v) => v as String),
        slots: $checkedConvert('slots', (v) => (v as num).toInt()),
        maxSlots: $checkedConvert('maxSlots', (v) => (v as num).toInt()),
        memberLimit: $checkedConvert('memberLimit', (v) => (v as num).toInt()),
        members: $checkedConvert('members', (v) => (v as num).toInt()),
        creditsBalance: $checkedConvert(
          'creditsBalance',
          (v) => (v as num).toInt(),
        ),
        trialEndsAt: $checkedConvert(
          'trialEndsAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        monthlyUzs: $checkedConvert('monthlyUzs', (v) => (v as num?)?.toInt()),
        ledger: $checkedConvert(
          'ledger',
          (v) => (v as List<dynamic>)
              .map((e) => LedgerEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        prices: $checkedConvert(
          'prices',
          (v) => BillingPrices.fromJson(v as Map<String, dynamic>),
        ),
        paymentsEnabled: $checkedConvert('paymentsEnabled', (v) => v as bool),
        selfHosted: $checkedConvert('selfHosted', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$BillingToJson(Billing instance) => <String, dynamic>{
  'plan': instance.plan,
  'slots': instance.slots,
  'maxSlots': instance.maxSlots,
  'memberLimit': instance.memberLimit,
  'members': instance.members,
  'creditsBalance': instance.creditsBalance,
  'trialEndsAt': ?instance.trialEndsAt?.toIso8601String(),
  'monthlyUzs': ?instance.monthlyUzs,
  'ledger': instance.ledger.map((e) => e.toJson()).toList(),
  'prices': instance.prices.toJson(),
  'paymentsEnabled': instance.paymentsEnabled,
  'selfHosted': ?instance.selfHosted,
};
