//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_exchange.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiExchange {
  /// Returns a new [ApiExchange] instance.
  ApiExchange({

    required  this.id,

     this.case_,

     this.auth,

    required  this.method,

    required  this.url,

    required  this.status,

    required  this.ms,

     this.error,

     this.truncated,

     this.requestHeaders,

     this.requestBody,

     this.responseHeaders,

     this.responseBody,

     this.at,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'case',
    required: false,
    includeIfNull: false,
  )


  final String? case_;



      /// default, none or wrong
  @JsonKey(
    
    name: r'auth',
    required: false,
    includeIfNull: false,
  )


  final String? auth;



  @JsonKey(
    
    name: r'method',
    required: true,
    includeIfNull: false,
  )


  final String method;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



      /// 0 when no response came back
  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final int status;



  @JsonKey(
    
    name: r'ms',
    required: true,
    includeIfNull: false,
  )


  final int ms;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



  @JsonKey(
    
    name: r'truncated',
    required: false,
    includeIfNull: false,
  )


  final bool? truncated;



  @JsonKey(
    
    name: r'requestHeaders',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? requestHeaders;



  @JsonKey(
    
    name: r'requestBody',
    required: false,
    includeIfNull: false,
  )


  final String? requestBody;



  @JsonKey(
    
    name: r'responseHeaders',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? responseHeaders;



  @JsonKey(
    
    name: r'responseBody',
    required: false,
    includeIfNull: false,
  )


  final String? responseBody;



  @JsonKey(
    
    name: r'at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? at;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ApiExchange &&
      other.id == id &&
      other.case_ == case_ &&
      other.auth == auth &&
      other.method == method &&
      other.url == url &&
      other.status == status &&
      other.ms == ms &&
      other.error == error &&
      other.truncated == truncated &&
      other.requestHeaders == requestHeaders &&
      other.requestBody == requestBody &&
      other.responseHeaders == responseHeaders &&
      other.responseBody == responseBody &&
      other.at == at;

    @override
    int get hashCode =>
        id.hashCode +
        case_.hashCode +
        auth.hashCode +
        method.hashCode +
        url.hashCode +
        status.hashCode +
        ms.hashCode +
        error.hashCode +
        truncated.hashCode +
        requestHeaders.hashCode +
        requestBody.hashCode +
        responseHeaders.hashCode +
        responseBody.hashCode +
        at.hashCode;

  factory ApiExchange.fromJson(Map<String, dynamic> json) => _$ApiExchangeFromJson(json);

  Map<String, dynamic> toJson() => _$ApiExchangeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

