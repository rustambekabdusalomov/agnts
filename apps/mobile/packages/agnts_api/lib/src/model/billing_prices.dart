//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'billing_prices.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BillingPrices {
  /// Returns a new [BillingPrices] instance.
  BillingPrices({

    required  this.workspaceUzs,

    required  this.slotUzs,

    required  this.memberUzs,

    required  this.creditUzs,

    required  this.includedMembers,

    required  this.markup,
  });

  @JsonKey(
    
    name: r'workspaceUzs',
    required: true,
    includeIfNull: false,
  )


  final int workspaceUzs;



  @JsonKey(
    
    name: r'slotUzs',
    required: true,
    includeIfNull: false,
  )


  final int slotUzs;



  @JsonKey(
    
    name: r'memberUzs',
    required: true,
    includeIfNull: false,
  )


  final int memberUzs;



      /// Price of one credit ($0.01 of API cost at the markup)
  @JsonKey(
    
    name: r'creditUzs',
    required: true,
    includeIfNull: false,
  )


  final int creditUzs;



  @JsonKey(
    
    name: r'includedMembers',
    required: true,
    includeIfNull: false,
  )


  final int includedMembers;



  @JsonKey(
    
    name: r'markup',
    required: true,
    includeIfNull: false,
  )


  final num markup;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BillingPrices &&
      other.workspaceUzs == workspaceUzs &&
      other.slotUzs == slotUzs &&
      other.memberUzs == memberUzs &&
      other.creditUzs == creditUzs &&
      other.includedMembers == includedMembers &&
      other.markup == markup;

    @override
    int get hashCode =>
        workspaceUzs.hashCode +
        slotUzs.hashCode +
        memberUzs.hashCode +
        creditUzs.hashCode +
        includedMembers.hashCode +
        markup.hashCode;

  factory BillingPrices.fromJson(Map<String, dynamic> json) => _$BillingPricesFromJson(json);

  Map<String, dynamic> toJson() => _$BillingPricesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

