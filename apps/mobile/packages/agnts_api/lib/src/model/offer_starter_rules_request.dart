//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'offer_starter_rules_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OfferStarterRulesRequest {
  /// Returns a new [OfferStarterRulesRequest] instance.
  OfferStarterRulesRequest({

    required  this.pack,
  });

  @JsonKey(
    
    name: r'pack',
    required: true,
    includeIfNull: false,
  )


  final String pack;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OfferStarterRulesRequest &&
      other.pack == pack;

    @override
    int get hashCode =>
        pack.hashCode;

  factory OfferStarterRulesRequest.fromJson(Map<String, dynamic> json) => _$OfferStarterRulesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OfferStarterRulesRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

