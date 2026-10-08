//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'begin_totp200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BeginTotp200Response {
  /// Returns a new [BeginTotp200Response] instance.
  BeginTotp200Response({

    required  this.secret,

    required  this.url,
  });

  @JsonKey(
    
    name: r'secret',
    required: true,
    includeIfNull: false,
  )


  final String secret;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BeginTotp200Response &&
      other.secret == secret &&
      other.url == url;

    @override
    int get hashCode =>
        secret.hashCode +
        url.hashCode;

  factory BeginTotp200Response.fromJson(Map<String, dynamic> json) => _$BeginTotp200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BeginTotp200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

