//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'disable_totp_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DisableTotpRequest {
  /// Returns a new [DisableTotpRequest] instance.
  DisableTotpRequest({

    required  this.password,

     this.code,
  });

  @JsonKey(
    
    name: r'password',
    required: true,
    includeIfNull: false,
  )


  final String password;



  @JsonKey(
    
    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DisableTotpRequest &&
      other.password == password &&
      other.code == code;

    @override
    int get hashCode =>
        password.hashCode +
        code.hashCode;

  factory DisableTotpRequest.fromJson(Map<String, dynamic> json) => _$DisableTotpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DisableTotpRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

