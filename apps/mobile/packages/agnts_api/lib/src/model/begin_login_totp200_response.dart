//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'begin_login_totp200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BeginLoginTotp200Response {
  /// Returns a new [BeginLoginTotp200Response] instance.
  BeginLoginTotp200Response({

    required  this.secret,

    required  this.url,
  });

      /// Base32, for manual entry
  @JsonKey(
    
    name: r'secret',
    required: true,
    includeIfNull: false,
  )


  final String secret;



      /// otpauth:// URL, for a QR code
  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BeginLoginTotp200Response &&
      other.secret == secret &&
      other.url == url;

    @override
    int get hashCode =>
        secret.hashCode +
        url.hashCode;

  factory BeginLoginTotp200Response.fromJson(Map<String, dynamic> json) => _$BeginLoginTotp200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BeginLoginTotp200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

