//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_plane_webhook_secret_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetPlaneWebhookSecretRequest {
  /// Returns a new [SetPlaneWebhookSecretRequest] instance.
  SetPlaneWebhookSecretRequest({

    required  this.secret,
  });

  @JsonKey(
    
    name: r'secret',
    required: true,
    includeIfNull: false,
  )


  final String secret;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetPlaneWebhookSecretRequest &&
      other.secret == secret;

    @override
    int get hashCode =>
        secret.hashCode;

  factory SetPlaneWebhookSecretRequest.fromJson(Map<String, dynamic> json) => _$SetPlaneWebhookSecretRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetPlaneWebhookSecretRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

