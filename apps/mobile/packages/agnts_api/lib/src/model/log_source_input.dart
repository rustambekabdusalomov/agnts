//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/log_auth_input.dart';
import 'package:agnts_api/src/model/log_scope.dart';
import 'package:agnts_api/src/model/log_fields.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_source_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogSourceInput {
  /// Returns a new [LogSourceInput] instance.
  LogSourceInput({

     this.id,

    required  this.name,

    required  this.kind,

    required  this.environment,

     this.address,

     this.auth,

     this.caPem,

     this.scope,

     this.fields,

     this.pollSeconds,

    required  this.enabled,
  });

      /// For a test of a saved source
  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final LogSourceInputKindEnum kind;



  @JsonKey(
    
    name: r'environment',
    required: true,
    includeIfNull: false,
  )


  final LogSourceInputEnvironmentEnum environment;



      /// https://loki.example.com, or http:// on a private network; empty for push
  @JsonKey(
    
    name: r'address',
    required: false,
    includeIfNull: false,
  )


  final String? address;



  @JsonKey(
    
    name: r'auth',
    required: false,
    includeIfNull: false,
  )


  final LogAuthInput? auth;



  @JsonKey(
    
    name: r'caPem',
    required: false,
    includeIfNull: false,
  )


  final String? caPem;



  @JsonKey(
    
    name: r'scope',
    required: false,
    includeIfNull: false,
  )


  final LogScope? scope;



  @JsonKey(
    
    name: r'fields',
    required: false,
    includeIfNull: false,
  )


  final LogFields? fields;



      /// How often agnts reads it (15 by default)
          // minimum: 5
          // maximum: 300
  @JsonKey(
    
    name: r'pollSeconds',
    required: false,
    includeIfNull: false,
  )


  final int? pollSeconds;



  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogSourceInput &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.environment == environment &&
      other.address == address &&
      other.auth == auth &&
      other.caPem == caPem &&
      other.scope == scope &&
      other.fields == fields &&
      other.pollSeconds == pollSeconds &&
      other.enabled == enabled;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        kind.hashCode +
        environment.hashCode +
        address.hashCode +
        auth.hashCode +
        caPem.hashCode +
        scope.hashCode +
        fields.hashCode +
        pollSeconds.hashCode +
        enabled.hashCode;

  factory LogSourceInput.fromJson(Map<String, dynamic> json) => _$LogSourceInputFromJson(json);

  Map<String, dynamic> toJson() => _$LogSourceInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum LogSourceInputKindEnum {
@JsonValue(r'loki')
loki(r'loki'),
@JsonValue(r'elasticsearch')
elasticsearch(r'elasticsearch'),
@JsonValue(r'opensearch')
opensearch(r'opensearch'),
@JsonValue(r'graylog')
graylog(r'graylog'),
@JsonValue(r'datadog')
datadog(r'datadog'),
@JsonValue(r'cloudwatch')
cloudwatch(r'cloudwatch'),
@JsonValue(r'splunk')
splunk(r'splunk'),
@JsonValue(r'push')
push(r'push');

const LogSourceInputKindEnum(this.value);

final String value;

@override
String toString() => value;
}


enum LogSourceInputEnvironmentEnum {
@JsonValue(r'production')
production(r'production'),
@JsonValue(r'staging')
staging(r'staging'),
@JsonValue(r'development')
development(r'development');

const LogSourceInputEnvironmentEnum(this.value);

final String value;

@override
String toString() => value;
}


