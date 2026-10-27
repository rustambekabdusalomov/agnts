//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_free_credits_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetFreeCreditsRequest {
  /// Returns a new [SetFreeCreditsRequest] instance.
  SetFreeCreditsRequest({

    required  this.limit,
  });

      /// Credits (1 credit = $0.01 of model cost)
          // minimum: 0
          // maximum: 10000000
  @JsonKey(
    
    name: r'limit',
    required: true,
    includeIfNull: false,
  )


  final int limit;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetFreeCreditsRequest &&
      other.limit == limit;

    @override
    int get hashCode =>
        limit.hashCode;

  factory SetFreeCreditsRequest.fromJson(Map<String, dynamic> json) => _$SetFreeCreditsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetFreeCreditsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

