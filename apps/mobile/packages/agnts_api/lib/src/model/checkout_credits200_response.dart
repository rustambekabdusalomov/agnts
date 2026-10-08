//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'checkout_credits200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CheckoutCredits200Response {
  /// Returns a new [CheckoutCredits200Response] instance.
  CheckoutCredits200Response({

    required  this.url,

    required  this.paymentId,
  });

  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'paymentId',
    required: true,
    includeIfNull: false,
  )


  final int paymentId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CheckoutCredits200Response &&
      other.url == url &&
      other.paymentId == paymentId;

    @override
    int get hashCode =>
        url.hashCode +
        paymentId.hashCode;

  factory CheckoutCredits200Response.fromJson(Map<String, dynamic> json) => _$CheckoutCredits200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutCredits200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

