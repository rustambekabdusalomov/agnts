//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_consent200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GetConsent200Response {
  /// Returns a new [GetConsent200Response] instance.
  GetConsent200Response({

    required  this.clientName,

    required  this.redirectHost,
  });

  @JsonKey(
    
    name: r'clientName',
    required: true,
    includeIfNull: false,
  )


  final String clientName;



  @JsonKey(
    
    name: r'redirectHost',
    required: true,
    includeIfNull: false,
  )


  final String redirectHost;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GetConsent200Response &&
      other.clientName == clientName &&
      other.redirectHost == redirectHost;

    @override
    int get hashCode =>
        clientName.hashCode +
        redirectHost.hashCode;

  factory GetConsent200Response.fromJson(Map<String, dynamic> json) => _$GetConsent200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetConsent200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

