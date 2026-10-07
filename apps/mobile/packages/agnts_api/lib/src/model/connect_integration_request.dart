//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'connect_integration_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConnectIntegrationRequest {
  /// Returns a new [ConnectIntegrationRequest] instance.
  ConnectIntegrationRequest({

    required  this.token,

     this.webhookSecret,

     this.settings,
  });

  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



      /// Plane: the secret Plane shows when you create the webhook. Empty keeps the stored one.
  @JsonKey(
    
    name: r'webhookSecret',
    required: false,
    includeIfNull: false,
  )


  final String? webhookSecret;



  @JsonKey(
    
    name: r'settings',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? settings;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConnectIntegrationRequest &&
      other.token == token &&
      other.webhookSecret == webhookSecret &&
      other.settings == settings;

    @override
    int get hashCode =>
        token.hashCode +
        webhookSecret.hashCode +
        settings.hashCode;

  factory ConnectIntegrationRequest.fromJson(Map<String, dynamic> json) => _$ConnectIntegrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectIntegrationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

