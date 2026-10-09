//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'google_sign_in_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GoogleSignInRequest {
  /// Returns a new [GoogleSignInRequest] instance.
  GoogleSignInRequest({

    required  this.idToken,

     this.invite,
  });

      /// The ID token Google Sign-In gave the app
  @JsonKey(
    
    name: r'idToken',
    required: true,
    includeIfNull: false,
  )


  final String idToken;



      /// An invite link's token, to join that workspace
  @JsonKey(
    
    name: r'invite',
    required: false,
    includeIfNull: false,
  )


  final String? invite;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GoogleSignInRequest &&
      other.idToken == idToken &&
      other.invite == invite;

    @override
    int get hashCode =>
        idToken.hashCode +
        invite.hashCode;

  factory GoogleSignInRequest.fromJson(Map<String, dynamic> json) => _$GoogleSignInRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleSignInRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

