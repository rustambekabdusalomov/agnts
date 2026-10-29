//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_fallback_limit_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetFallbackLimitRequest {
  /// Returns a new [SetFallbackLimitRequest] instance.
  SetFallbackLimitRequest({

    required  this.limit,
  });

      /// Credits per month (1 credit = $0.01 of model cost); 0 is no limit; null follows the server's default
          // minimum: 0
          // maximum: 10000000
  @JsonKey(
    
    name: r'limit',
    required: true,
    includeIfNull: true,
  )


  final int? limit;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetFallbackLimitRequest &&
      other.limit == limit;

    @override
    int get hashCode =>
        (limit == null ? 0 : limit.hashCode);

  factory SetFallbackLimitRequest.fromJson(Map<String, dynamic> json) => _$SetFallbackLimitRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetFallbackLimitRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

