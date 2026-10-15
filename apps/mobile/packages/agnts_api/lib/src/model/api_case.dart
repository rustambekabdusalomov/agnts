//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_case.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiCase {
  /// Returns a new [ApiCase] instance.
  ApiCase({

    required  this.id,

    required  this.operation,

    required  this.case_,

     this.expected,

    required  this.verdict,

     this.reason,

    required  this.requests,

    required  this.source_,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'operation',
    required: true,
    includeIfNull: false,
  )


  final String operation;



  @JsonKey(
    
    name: r'case',
    required: true,
    includeIfNull: false,
  )


  final String case_;



  @JsonKey(
    
    name: r'expected',
    required: false,
    includeIfNull: false,
  )


  final String? expected;



  @JsonKey(
    
    name: r'verdict',
    required: true,
    includeIfNull: false,
  )


  final ApiCaseVerdictEnum verdict;



  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;



  @JsonKey(
    
    name: r'requests',
    required: true,
    includeIfNull: false,
  )


  final List<String> requests;



      /// schema: agnts's own check of the response against the spec
  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final ApiCaseSource_Enum source_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ApiCase &&
      other.id == id &&
      other.operation == operation &&
      other.case_ == case_ &&
      other.expected == expected &&
      other.verdict == verdict &&
      other.reason == reason &&
      other.requests == requests &&
      other.source_ == source_;

    @override
    int get hashCode =>
        id.hashCode +
        operation.hashCode +
        case_.hashCode +
        expected.hashCode +
        verdict.hashCode +
        reason.hashCode +
        requests.hashCode +
        source_.hashCode;

  factory ApiCase.fromJson(Map<String, dynamic> json) => _$ApiCaseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiCaseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ApiCaseVerdictEnum {
@JsonValue(r'pass')
pass(r'pass'),
@JsonValue(r'fail')
fail(r'fail'),
@JsonValue(r'skipped')
skipped(r'skipped'),
@JsonValue(r'blocked')
blocked(r'blocked');

const ApiCaseVerdictEnum(this.value);

final String value;

@override
String toString() => value;
}


/// schema: agnts's own check of the response against the spec
enum ApiCaseSource_Enum {
@JsonValue(r'claude')
claude(r'claude'),
@JsonValue(r'schema')
schema(r'schema');

const ApiCaseSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


