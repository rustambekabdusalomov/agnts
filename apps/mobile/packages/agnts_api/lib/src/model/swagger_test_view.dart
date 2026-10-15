//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/api_auth_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_test_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerTestView {
  /// Returns a new [SwaggerTestView] instance.
  SwaggerTestView({

     this.specUrl,

    required  this.baseUrl,

    required  this.operations,

    required  this.writeEnabled,

    required  this.authKind,

     this.authName,

    required  this.hasToken,

    required  this.rateLimit,

    required  this.maxRequests,

     this.suiteId,
  });

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



  @JsonKey(
    
    name: r'operations',
    required: true,
    includeIfNull: false,
  )


  final List<String> operations;



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
    
    name: r'authName',
    required: false,
    includeIfNull: false,
  )


  final String? authName;



      /// A sealed token is stored (never returned)
  @JsonKey(
    
    name: r'hasToken',
    required: true,
    includeIfNull: false,
  )


  final bool hasToken;



  @JsonKey(
    
    name: r'rateLimit',
    required: true,
    includeIfNull: false,
  )


  final int rateLimit;



  @JsonKey(
    
    name: r'maxRequests',
    required: true,
    includeIfNull: false,
  )


  final int maxRequests;



  @JsonKey(
    
    name: r'suiteId',
    required: false,
    includeIfNull: false,
  )


  final int? suiteId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerTestView &&
      other.specUrl == specUrl &&
      other.baseUrl == baseUrl &&
      other.operations == operations &&
      other.writeEnabled == writeEnabled &&
      other.authKind == authKind &&
      other.authName == authName &&
      other.hasToken == hasToken &&
      other.rateLimit == rateLimit &&
      other.maxRequests == maxRequests &&
      other.suiteId == suiteId;

    @override
    int get hashCode =>
        specUrl.hashCode +
        baseUrl.hashCode +
        operations.hashCode +
        writeEnabled.hashCode +
        authKind.hashCode +
        authName.hashCode +
        hasToken.hashCode +
        rateLimit.hashCode +
        maxRequests.hashCode +
        suiteId.hashCode;

  factory SwaggerTestView.fromJson(Map<String, dynamic> json) => _$SwaggerTestViewFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerTestViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

