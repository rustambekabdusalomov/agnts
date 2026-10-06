//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'decide_consent200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DecideConsent200Response {
  /// Returns a new [DecideConsent200Response] instance.
  DecideConsent200Response({

    required  this.redirect,
  });

  @JsonKey(
    
    name: r'redirect',
    required: true,
    includeIfNull: false,
  )


  final String redirect;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DecideConsent200Response &&
      other.redirect == redirect;

    @override
    int get hashCode =>
        redirect.hashCode;

  factory DecideConsent200Response.fromJson(Map<String, dynamic> json) => _$DecideConsent200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DecideConsent200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

