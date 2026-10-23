//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'guest_session.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GuestSession {
  /// Returns a new [GuestSession] instance.
  GuestSession({

    required  this.token,

    required  this.name,

    required  this.via,
  });

      /// Send it as X-Guest-Token
  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'via',
    required: true,
    includeIfNull: false,
  )


  final GuestSessionViaEnum via;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GuestSession &&
      other.token == token &&
      other.name == name &&
      other.via == via;

    @override
    int get hashCode =>
        token.hashCode +
        name.hashCode +
        via.hashCode;

  factory GuestSession.fromJson(Map<String, dynamic> json) => _$GuestSessionFromJson(json);

  Map<String, dynamic> toJson() => _$GuestSessionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum GuestSessionViaEnum {
@JsonValue(r'name')
name(r'name'),
@JsonValue(r'google')
google(r'google'),
@JsonValue(r'account')
account(r'account');

const GuestSessionViaEnum(this.value);

final String value;

@override
String toString() => value;
}


