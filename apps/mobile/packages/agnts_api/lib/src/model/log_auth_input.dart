//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_auth_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogAuthInput {
  /// Returns a new [LogAuthInput] instance.
  LogAuthInput({

    required  this.kind,

     this.user,

     this.password,

     this.token,

     this.tenant,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final LogAuthInputKindEnum kind;



  @JsonKey(
    
    name: r'user',
    required: false,
    includeIfNull: false,
  )


  final String? user;



  @JsonKey(
    
    name: r'password',
    required: false,
    includeIfNull: false,
  )


  final String? password;



  @JsonKey(
    
    name: r'token',
    required: false,
    includeIfNull: false,
  )


  final String? token;



      /// Loki's X-Scope-OrgID
  @JsonKey(
    
    name: r'tenant',
    required: false,
    includeIfNull: false,
  )


  final String? tenant;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogAuthInput &&
      other.kind == kind &&
      other.user == user &&
      other.password == password &&
      other.token == token &&
      other.tenant == tenant;

    @override
    int get hashCode =>
        kind.hashCode +
        user.hashCode +
        password.hashCode +
        token.hashCode +
        tenant.hashCode;

  factory LogAuthInput.fromJson(Map<String, dynamic> json) => _$LogAuthInputFromJson(json);

  Map<String, dynamic> toJson() => _$LogAuthInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum LogAuthInputKindEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'basic')
basic(r'basic'),
@JsonValue(r'bearer')
bearer(r'bearer'),
@JsonValue(r'apikey')
apikey(r'apikey'),
@JsonValue(r'aws')
aws(r'aws');

const LogAuthInputKindEnum(this.value);

final String value;

@override
String toString() => value;
}


