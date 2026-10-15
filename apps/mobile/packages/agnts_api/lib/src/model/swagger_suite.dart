//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/api_auth_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_suite.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerSuite {
  /// Returns a new [SwaggerSuite] instance.
  SwaggerSuite({

    required  this.id,

    required  this.name,

     this.specUrl,

    required  this.baseUrl,

    required  this.operations,

    required  this.writeEnabled,

    required  this.authKind,

    required  this.hasToken,

     this.repoId,

    required  this.schedule,

    required  this.hour,

    required  this.enabled,

    required  this.hookSet,

     this.lastRunAt,

     this.nextRunAt,

     this.lastTicketKey,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'specUrl',
    required: false,
    includeIfNull: false,
  )


  final String? specUrl;



  @JsonKey(
    
    name: r'baseUrl',
    required: true,
    includeIfNull: false,
  )


  final String baseUrl;



      /// How many endpoints it tests
  @JsonKey(
    
    name: r'operations',
    required: true,
    includeIfNull: false,
  )


  final int operations;



  @JsonKey(
    
    name: r'writeEnabled',
    required: true,
    includeIfNull: false,
  )


  final bool writeEnabled;



  @JsonKey(
    
    name: r'authKind',
    required: true,
    includeIfNull: false,
  )


  final ApiAuthKind authKind;



  @JsonKey(
    
    name: r'hasToken',
    required: true,
    includeIfNull: false,
  )


  final bool hasToken;



  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



  @JsonKey(
    
    name: r'schedule',
    required: true,
    includeIfNull: false,
  )


  final SwaggerSuiteScheduleEnum schedule;



  @JsonKey(
    
    name: r'hour',
    required: true,
    includeIfNull: false,
  )


  final int hour;



  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;



      /// A deploy hook URL exists
  @JsonKey(
    
    name: r'hookSet',
    required: true,
    includeIfNull: false,
  )


  final bool hookSet;



  @JsonKey(
    
    name: r'lastRunAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastRunAt;



  @JsonKey(
    
    name: r'nextRunAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? nextRunAt;



  @JsonKey(
    
    name: r'lastTicketKey',
    required: false,
    includeIfNull: false,
  )


  final String? lastTicketKey;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerSuite &&
      other.id == id &&
      other.name == name &&
      other.specUrl == specUrl &&
      other.baseUrl == baseUrl &&
      other.operations == operations &&
      other.writeEnabled == writeEnabled &&
      other.authKind == authKind &&
      other.hasToken == hasToken &&
      other.repoId == repoId &&
      other.schedule == schedule &&
      other.hour == hour &&
      other.enabled == enabled &&
      other.hookSet == hookSet &&
      other.lastRunAt == lastRunAt &&
      other.nextRunAt == nextRunAt &&
      other.lastTicketKey == lastTicketKey &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        specUrl.hashCode +
        baseUrl.hashCode +
        operations.hashCode +
        writeEnabled.hashCode +
        authKind.hashCode +
        hasToken.hashCode +
        repoId.hashCode +
        schedule.hashCode +
        hour.hashCode +
        enabled.hashCode +
        hookSet.hashCode +
        lastRunAt.hashCode +
        nextRunAt.hashCode +
        lastTicketKey.hashCode +
        createdAt.hashCode;

  factory SwaggerSuite.fromJson(Map<String, dynamic> json) => _$SwaggerSuiteFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerSuiteToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum SwaggerSuiteScheduleEnum {
@JsonValue(r'off')
off(r'off'),
@JsonValue(r'hourly')
hourly(r'hourly'),
@JsonValue(r'daily')
daily(r'daily'),
@JsonValue(r'weekly')
weekly(r'weekly');

const SwaggerSuiteScheduleEnum(this.value);

final String value;

@override
String toString() => value;
}


