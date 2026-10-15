//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/api_auth_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_auth_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerAuthInput {
  /// Returns a new [SwaggerAuthInput] instance.
  SwaggerAuthInput({

    required  this.kind,

     this.name,

     this.value,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final ApiAuthKind kind;



      /// The header or query parameter of an API key
  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



      /// The token (user:password for basic). Sealed, never returned, deleted when the ticket closes
  @JsonKey(
    
    name: r'value',
    required: false,
    includeIfNull: false,
  )


  final String? value;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerAuthInput &&
      other.kind == kind &&
      other.name == name &&
      other.value == value;

    @override
    int get hashCode =>
        kind.hashCode +
        name.hashCode +
        value.hashCode;

  factory SwaggerAuthInput.fromJson(Map<String, dynamic> json) => _$SwaggerAuthInputFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerAuthInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

