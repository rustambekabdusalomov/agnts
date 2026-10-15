//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/swagger_spec_choices_inner.dart';
import 'package:agnts_api/src/model/swagger_operation.dart';
import 'package:agnts_api/src/model/swagger_security_scheme.dart';
import 'package:agnts_api/src/model/swagger_server.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_spec.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerSpec {
  /// Returns a new [SwaggerSpec] instance.
  SwaggerSpec({

     this.specRef,

     this.url,

     this.title,

     this.version,

     this.format,

    required  this.servers,

    required  this.operations,

    required  this.securitySchemes,

    required  this.choices,
  });

      /// An uploaded spec, or one fetched with a token, kept for an hour: pass it to createSwaggerTest
  @JsonKey(
    
    name: r'specRef',
    required: false,
    includeIfNull: false,
  )


  final String? specRef;



      /// Where the spec was found (a docs page leads to its spec)
  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'version',
    required: false,
    includeIfNull: false,
  )


  final String? version;



      /// \"swagger 2.0\" or \"openapi 3.x\"
  @JsonKey(
    
    name: r'format',
    required: false,
    includeIfNull: false,
  )


  final String? format;



  @JsonKey(
    
    name: r'servers',
    required: true,
    includeIfNull: false,
  )


  final List<SwaggerServer> servers;



  @JsonKey(
    
    name: r'operations',
    required: true,
    includeIfNull: false,
  )


  final List<SwaggerOperation> operations;



  @JsonKey(
    
    name: r'securitySchemes',
    required: true,
    includeIfNull: false,
  )


  final List<SwaggerSecurityScheme> securitySchemes;



      /// The specs a docs page offers; read the chosen one's url
  @JsonKey(
    
    name: r'choices',
    required: true,
    includeIfNull: false,
  )


  final List<SwaggerSpecChoicesInner> choices;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerSpec &&
      other.specRef == specRef &&
      other.url == url &&
      other.title == title &&
      other.version == version &&
      other.format == format &&
      other.servers == servers &&
      other.operations == operations &&
      other.securitySchemes == securitySchemes &&
      other.choices == choices;

    @override
    int get hashCode =>
        specRef.hashCode +
        url.hashCode +
        title.hashCode +
        version.hashCode +
        format.hashCode +
        servers.hashCode +
        operations.hashCode +
        securitySchemes.hashCode +
        choices.hashCode;

  factory SwaggerSpec.fromJson(Map<String, dynamic> json) => _$SwaggerSpecFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerSpecToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

