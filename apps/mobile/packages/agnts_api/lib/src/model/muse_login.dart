//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'muse_login.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MuseLogin {
  /// Returns a new [MuseLogin] instance.
  MuseLogin({

    required  this.id,

    required  this.userCode,

    required  this.verificationUri,

     this.verificationUriComplete,

    required  this.expiresAt,

    required  this.status,

     this.error,

     this.account,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



      /// The code to confirm on Meta's page
  @JsonKey(
    
    name: r'userCode',
    required: true,
    includeIfNull: false,
  )


  final String userCode;



  @JsonKey(
    
    name: r'verificationUri',
    required: true,
    includeIfNull: false,
  )


  final String verificationUri;



      /// The page with the code filled in
  @JsonKey(
    
    name: r'verificationUriComplete',
    required: false,
    includeIfNull: false,
  )


  final String? verificationUriComplete;



  @JsonKey(
    
    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime expiresAt;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final MuseLoginStatusEnum status;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



  @JsonKey(
    
    name: r'account',
    required: false,
    includeIfNull: false,
  )


  final String? account;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MuseLogin &&
      other.id == id &&
      other.userCode == userCode &&
      other.verificationUri == verificationUri &&
      other.verificationUriComplete == verificationUriComplete &&
      other.expiresAt == expiresAt &&
      other.status == status &&
      other.error == error &&
      other.account == account;

    @override
    int get hashCode =>
        id.hashCode +
        userCode.hashCode +
        verificationUri.hashCode +
        verificationUriComplete.hashCode +
        expiresAt.hashCode +
        status.hashCode +
        error.hashCode +
        account.hashCode;

  factory MuseLogin.fromJson(Map<String, dynamic> json) => _$MuseLoginFromJson(json);

  Map<String, dynamic> toJson() => _$MuseLoginToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MuseLoginStatusEnum {
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'connected')
connected(r'connected'),
@JsonValue(r'denied')
denied(r'denied'),
@JsonValue(r'expired')
expired(r'expired'),
@JsonValue(r'failed')
failed(r'failed');

const MuseLoginStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


