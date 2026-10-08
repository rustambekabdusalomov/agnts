//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'checkout_credits_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CheckoutCreditsRequest {
  /// Returns a new [CheckoutCreditsRequest] instance.
  CheckoutCreditsRequest({

    required  this.amountUzs,

    required  this.provider,
  });

      /// Amount to pay in so'm
          // minimum: 10000
  @JsonKey(
    
    name: r'amountUzs',
    required: true,
    includeIfNull: false,
  )


  final int amountUzs;



  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final CheckoutCreditsRequestProviderEnum provider;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CheckoutCreditsRequest &&
      other.amountUzs == amountUzs &&
      other.provider == provider;

    @override
    int get hashCode =>
        amountUzs.hashCode +
        provider.hashCode;

  factory CheckoutCreditsRequest.fromJson(Map<String, dynamic> json) => _$CheckoutCreditsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutCreditsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum CheckoutCreditsRequestProviderEnum {
@JsonValue(r'payme')
payme(r'payme'),
@JsonValue(r'click')
click(r'click');

const CheckoutCreditsRequestProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


