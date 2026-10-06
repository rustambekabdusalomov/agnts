//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rotate_mcp_token200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RotateMcpToken200Response {
  /// Returns a new [RotateMcpToken200Response] instance.
  RotateMcpToken200Response({

    required  this.token,
  });

  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RotateMcpToken200Response &&
      other.token == token;

    @override
    int get hashCode =>
        token.hashCode;

  factory RotateMcpToken200Response.fromJson(Map<String, dynamic> json) => _$RotateMcpToken200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RotateMcpToken200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

