//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_credit_limit_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetCreditLimitRequest {
  /// Returns a new [SetCreditLimitRequest] instance.
  SetCreditLimitRequest({

    required  this.limit,
  });

      /// Credits per month (1 credit = $0.01 of model cost); 0 is no limit
          // minimum: 0
          // maximum: 10000000
  @JsonKey(
    
    name: r'limit',
    required: true,
    includeIfNull: false,
  )


  final int limit;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetCreditLimitRequest &&
      other.limit == limit;

    @override
    int get hashCode =>
        limit.hashCode;

  factory SetCreditLimitRequest.fromJson(Map<String, dynamic> json) => _$SetCreditLimitRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetCreditLimitRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

