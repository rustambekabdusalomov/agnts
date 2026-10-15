//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/swagger_server_variables_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_server.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerServer {
  /// Returns a new [SwaggerServer] instance.
  SwaggerServer({

    required  this.url,

     this.description,

     this.variables,
  });

      /// Variables filled with their defaults; relative URLs resolved against the spec URL
  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'variables',
    required: false,
    includeIfNull: false,
  )


  final List<SwaggerServerVariablesInner>? variables;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerServer &&
      other.url == url &&
      other.description == description &&
      other.variables == variables;

    @override
    int get hashCode =>
        url.hashCode +
        description.hashCode +
        variables.hashCode;

  factory SwaggerServer.fromJson(Map<String, dynamic> json) => _$SwaggerServerFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerServerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

