//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'confirm_totp_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmTotpRequest {
  /// Returns a new [ConfirmTotpRequest] instance.
  ConfirmTotpRequest({

    required  this.secret,

    required  this.code,
  });

  @JsonKey(
    
    name: r'secret',
    required: true,
    includeIfNull: false,
  )


  final String secret;



  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConfirmTotpRequest &&
      other.secret == secret &&
      other.code == code;

    @override
    int get hashCode =>
        secret.hashCode +
        code.hashCode;

  factory ConfirmTotpRequest.fromJson(Map<String, dynamic> json) => _$ConfirmTotpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmTotpRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

