//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/billing_prices.dart';
import 'package:agnts_api/src/model/ledger_entry.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'billing.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Billing {
  /// Returns a new [Billing] instance.
  Billing({

    required  this.plan,

    required  this.slots,

    required  this.maxSlots,

    required  this.memberLimit,

    required  this.members,

    required  this.creditsBalance,

     this.trialEndsAt,

     this.monthlyUzs,

     this.monthlyUsd,

    required  this.ledger,

    required  this.prices,

    required  this.paymentsEnabled,

     this.selfHosted,
  });

  @JsonKey(
    
    name: r'plan',
    required: true,
    includeIfNull: false,
  )


  final String plan;



  @JsonKey(
    
    name: r'slots',
    required: true,
    includeIfNull: false,
  )


  final int slots;



  @JsonKey(
    
    name: r'maxSlots',
    required: true,
    includeIfNull: false,
  )


  final int maxSlots;



  @JsonKey(
    
    name: r'memberLimit',
    required: true,
    includeIfNull: false,
  )


  final int memberLimit;



  @JsonKey(
    
    name: r'members',
    required: true,
    includeIfNull: false,
  )


  final int members;



  @JsonKey(
    
    name: r'creditsBalance',
    required: true,
    includeIfNull: false,
  )


  final int creditsBalance;



  @JsonKey(
    
    name: r'trialEndsAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? trialEndsAt;



      /// What the plan, extra slots and extra members cost a month
  @JsonKey(
    
    name: r'monthlyUzs',
    required: false,
    includeIfNull: false,
  )


  final int? monthlyUzs;



      /// The same in US dollars, as the billing page shows it
  @JsonKey(
    
    name: r'monthlyUsd',
    required: false,
    includeIfNull: false,
  )


  final double? monthlyUsd;



  @JsonKey(
    
    name: r'ledger',
    required: true,
    includeIfNull: false,
  )


  final List<LedgerEntry> ledger;



  @JsonKey(
    
    name: r'prices',
    required: true,
    includeIfNull: false,
  )


  final BillingPrices prices;



  @JsonKey(
    
    name: r'paymentsEnabled',
    required: true,
    includeIfNull: false,
  )


  final bool paymentsEnabled;



      /// No billing: slots and members are set by the Admin
  @JsonKey(
    
    name: r'selfHosted',
    required: false,
    includeIfNull: false,
  )


  final bool? selfHosted;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Billing &&
      other.plan == plan &&
      other.slots == slots &&
      other.maxSlots == maxSlots &&
      other.memberLimit == memberLimit &&
      other.members == members &&
      other.creditsBalance == creditsBalance &&
      other.trialEndsAt == trialEndsAt &&
      other.monthlyUzs == monthlyUzs &&
      other.monthlyUsd == monthlyUsd &&
      other.ledger == ledger &&
      other.prices == prices &&
      other.paymentsEnabled == paymentsEnabled &&
      other.selfHosted == selfHosted;

    @override
    int get hashCode =>
        plan.hashCode +
        slots.hashCode +
        maxSlots.hashCode +
        memberLimit.hashCode +
        members.hashCode +
        creditsBalance.hashCode +
        trialEndsAt.hashCode +
        monthlyUzs.hashCode +
        monthlyUsd.hashCode +
        ledger.hashCode +
        prices.hashCode +
        paymentsEnabled.hashCode +
        selfHosted.hashCode;

  factory Billing.fromJson(Map<String, dynamic> json) => _$BillingFromJson(json);

  Map<String, dynamic> toJson() => _$BillingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

