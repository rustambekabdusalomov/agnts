//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'decide_consent_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DecideConsentRequest {
  /// Returns a new [DecideConsentRequest] instance.
  DecideConsentRequest({

    required  this.clientId,

    required  this.redirectUri,

    required  this.codeChallenge,

    required  this.codeChallengeMethod,

     this.state,

     this.resource,

    required  this.approve,
  });

  @JsonKey(
    
    name: r'clientId',
    required: true,
    includeIfNull: false,
  )


  final String clientId;



  @JsonKey(
    
    name: r'redirectUri',
    required: true,
    includeIfNull: false,
  )


  final String redirectUri;



  @JsonKey(
    
    name: r'codeChallenge',
    required: true,
    includeIfNull: false,
  )


  final String codeChallenge;



  @JsonKey(
    
    name: r'codeChallengeMethod',
    required: true,
    includeIfNull: false,
  )


  final String codeChallengeMethod;



  @JsonKey(
    
    name: r'state',
    required: false,
    includeIfNull: false,
  )


  final String? state;



  @JsonKey(
    
    name: r'resource',
    required: false,
    includeIfNull: false,
  )


  final String? resource;



  @JsonKey(
    
    name: r'approve',
    required: true,
    includeIfNull: false,
  )


  final bool approve;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DecideConsentRequest &&
      other.clientId == clientId &&
      other.redirectUri == redirectUri &&
      other.codeChallenge == codeChallenge &&
      other.codeChallengeMethod == codeChallengeMethod &&
      other.state == state &&
      other.resource == resource &&
      other.approve == approve;

    @override
    int get hashCode =>
        clientId.hashCode +
        redirectUri.hashCode +
        codeChallenge.hashCode +
        codeChallengeMethod.hashCode +
        state.hashCode +
        resource.hashCode +
        approve.hashCode;

  factory DecideConsentRequest.fromJson(Map<String, dynamic> json) => _$DecideConsentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DecideConsentRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

