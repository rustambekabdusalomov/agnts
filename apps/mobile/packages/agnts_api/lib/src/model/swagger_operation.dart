//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_operation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerOperation {
  /// Returns a new [SwaggerOperation] instance.
  SwaggerOperation({

    required  this.method,

    required  this.path,

     this.operationId,

     this.summary,

     this.tags,

     this.deprecated,

     this.sideEffect,

     this.security,

    required  this.default_,
  });

  @JsonKey(
    
    name: r'method',
    required: true,
    includeIfNull: false,
  )


  final String method;



  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'operationId',
    required: false,
    includeIfNull: false,
  )


  final String? operationId;



  @JsonKey(
    
    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final String? summary;



  @JsonKey(
    
    name: r'tags',
    required: false,
    includeIfNull: false,
  )


  final List<String>? tags;



  @JsonKey(
    
    name: r'deprecated',
    required: false,
    includeIfNull: false,
  )


  final bool? deprecated;



      /// Why a GET probably changes something (logout, export, send ...); such operations start unticked
  @JsonKey(
    
    name: r'sideEffect',
    required: false,
    includeIfNull: false,
  )


  final String? sideEffect;



  @JsonKey(
    
    name: r'security',
    required: false,
    includeIfNull: false,
  )


  final List<String>? security;



      /// Ticked in the form by default
  @JsonKey(
    
    name: r'default',
    required: true,
    includeIfNull: false,
  )


  final bool default_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerOperation &&
      other.method == method &&
      other.path == path &&
      other.operationId == operationId &&
      other.summary == summary &&
      other.tags == tags &&
      other.deprecated == deprecated &&
      other.sideEffect == sideEffect &&
      other.security == security &&
      other.default_ == default_;

    @override
    int get hashCode =>
        method.hashCode +
        path.hashCode +
        operationId.hashCode +
        summary.hashCode +
        tags.hashCode +
        deprecated.hashCode +
        sideEffect.hashCode +
        security.hashCode +
        default_.hashCode;

  factory SwaggerOperation.fromJson(Map<String, dynamic> json) => _$SwaggerOperationFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerOperationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

