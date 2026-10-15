//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_server_variables_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerServerVariablesInner {
  /// Returns a new [SwaggerServerVariablesInner] instance.
  SwaggerServerVariablesInner({

    required  this.name,

    required  this.default_,

     this.enum_,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'default',
    required: true,
    includeIfNull: false,
  )


  final String default_;



  @JsonKey(
    
    name: r'enum',
    required: false,
    includeIfNull: false,
  )


  final List<String>? enum_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerServerVariablesInner &&
      other.name == name &&
      other.default_ == default_ &&
      other.enum_ == enum_;

    @override
    int get hashCode =>
        name.hashCode +
        default_.hashCode +
        enum_.hashCode;

  factory SwaggerServerVariablesInner.fromJson(Map<String, dynamic> json) => _$SwaggerServerVariablesInnerFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerServerVariablesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

