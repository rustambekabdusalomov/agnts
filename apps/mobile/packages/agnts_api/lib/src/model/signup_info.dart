//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'signup_info.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SignupInfo {
  /// Returns a new [SignupInfo] instance.
  SignupInfo({

    required  this.open,

    required  this.firstUser,

    required  this.emailEnabled,
  });

      /// Anyone can register; otherwise only with an invite link
  @JsonKey(
    
    name: r'open',
    required: true,
    includeIfNull: false,
  )


  final bool open;



      /// No account exists yet; the first one becomes Admin
  @JsonKey(
    
    name: r'firstUser',
    required: true,
    includeIfNull: false,
  )


  final bool firstUser;



      /// The server can send email (verification, invites, resets)
  @JsonKey(
    
    name: r'emailEnabled',
    required: true,
    includeIfNull: false,
  )


  final bool emailEnabled;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SignupInfo &&
      other.open == open &&
      other.firstUser == firstUser &&
      other.emailEnabled == emailEnabled;

    @override
    int get hashCode =>
        open.hashCode +
        firstUser.hashCode +
        emailEnabled.hashCode;

  factory SignupInfo.fromJson(Map<String, dynamic> json) => _$SignupInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SignupInfoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

