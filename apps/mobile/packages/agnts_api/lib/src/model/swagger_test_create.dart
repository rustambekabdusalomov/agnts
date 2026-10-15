//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/swagger_auth_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_test_create.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerTestCreate {
  /// Returns a new [SwaggerTestCreate] instance.
  SwaggerTestCreate({

     this.title,

     this.specUrl,

     this.specRef,

    required  this.baseUrl,

     this.operations,

     this.writeEnabled,

     this.notProduction,

     this.auth,

     this.repoId,

     this.notes,

     this.rateLimit,

     this.maxRequests,

     this.priority,

     this.start,
  });

      /// Defaults to \"Swagger test: <API> on <host>\"
  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



      /// The URL readSwaggerSpec read (served from its cache)
  @JsonKey(
    
    name: r'specUrl',
    required: false,
    includeIfNull: false,
  )


  final String? specUrl;



      /// An uploaded spec, from readSwaggerSpec
  @JsonKey(
    
    name: r'specRef',
    required: false,
    includeIfNull: false,
  )


  final String? specRef;



  @JsonKey(
    
    name: r'baseUrl',
    required: true,
    includeIfNull: false,
  )


  final String baseUrl;



  @JsonKey(
    
    name: r'operations',
    required: false,
    includeIfNull: false,
  )


  final List<String>? operations;



      /// Send POST, PUT, PATCH and DELETE too; off by default
  @JsonKey(
    
    name: r'writeEnabled',
    required: false,
    includeIfNull: false,
  )


  final bool? writeEnabled;



      /// Confirms the base URL is not production; required with writeEnabled
  @JsonKey(
    
    name: r'notProduction',
    required: false,
    includeIfNull: false,
  )


  final bool? notProduction;



  @JsonKey(
    
    name: r'auth',
    required: false,
    includeIfNull: false,
  )


  final SwaggerAuthInput? auth;



      /// Optional: the API's repository, to explain failures
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



      /// What to test: which endpoints, cases or data. Without operations, it decides the scope.
  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



      /// Requests a second (0: 5)
          // minimum: 0
          // maximum: 20
  @JsonKey(
    
    name: r'rateLimit',
    required: false,
    includeIfNull: false,
  )


  final int? rateLimit;



      /// Requests per run (0: 300)
          // minimum: 0
          // maximum: 1000
  @JsonKey(
    
    name: r'maxRequests',
    required: false,
    includeIfNull: false,
  )


  final int? maxRequests;



  @JsonKey(
    
    name: r'priority',
    required: false,
    includeIfNull: false,
  )


  final SwaggerTestCreatePriorityEnum? priority;



      /// code starts now; queue keeps it until started
  @JsonKey(
    
    name: r'start',
    required: false,
    includeIfNull: false,
  )


  final SwaggerTestCreateStartEnum? start;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerTestCreate &&
      other.title == title &&
      other.specUrl == specUrl &&
      other.specRef == specRef &&
      other.baseUrl == baseUrl &&
      other.operations == operations &&
      other.writeEnabled == writeEnabled &&
      other.notProduction == notProduction &&
      other.auth == auth &&
      other.repoId == repoId &&
      other.notes == notes &&
      other.rateLimit == rateLimit &&
      other.maxRequests == maxRequests &&
      other.priority == priority &&
      other.start == start;

    @override
    int get hashCode =>
        title.hashCode +
        specUrl.hashCode +
        specRef.hashCode +
        baseUrl.hashCode +
        operations.hashCode +
        writeEnabled.hashCode +
        notProduction.hashCode +
        auth.hashCode +
        repoId.hashCode +
        notes.hashCode +
        rateLimit.hashCode +
        maxRequests.hashCode +
        priority.hashCode +
        start.hashCode;

  factory SwaggerTestCreate.fromJson(Map<String, dynamic> json) => _$SwaggerTestCreateFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerTestCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum SwaggerTestCreatePriorityEnum {
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high');

const SwaggerTestCreatePriorityEnum(this.value);

final String value;

@override
String toString() => value;
}


/// code starts now; queue keeps it until started
enum SwaggerTestCreateStartEnum {
@JsonValue(r'code')
code(r'code'),
@JsonValue(r'queue')
queue(r'queue');

const SwaggerTestCreateStartEnum(this.value);

final String value;

@override
String toString() => value;
}


