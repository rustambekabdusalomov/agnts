//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/log_service.dart';
import 'package:agnts_api/src/model/log_scope.dart';
import 'package:agnts_api/src/model/log_fields.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_source.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogSource {
  /// Returns a new [LogSource] instance.
  LogSource({

    required  this.id,

    required  this.name,

    required  this.kind,

    required  this.environment,

    required  this.address,

    required  this.authKind,

     this.authUser,

     this.authTenant,

    required  this.hasAuth,

    required  this.caPem,

    required  this.scope,

    required  this.fields,

    required  this.pollSeconds,

    required  this.enabled,

    required  this.status,

    required  this.lastError,

     this.lastReadAt,

     this.gapFrom,

     this.gapTo,

    required  this.dropped,

     this.networkId,

    required  this.hasPushToken,

     this.pushUrl,

    required  this.services,

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
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final LogSourceKindEnum kind;



  @JsonKey(
    
    name: r'environment',
    required: true,
    includeIfNull: false,
  )


  final String environment;



  @JsonKey(
    
    name: r'address',
    required: true,
    includeIfNull: false,
  )


  final String address;



  @JsonKey(
    
    name: r'authKind',
    required: true,
    includeIfNull: false,
  )


  final String authKind;



  @JsonKey(
    
    name: r'authUser',
    required: false,
    includeIfNull: false,
  )


  final String? authUser;



  @JsonKey(
    
    name: r'authTenant',
    required: false,
    includeIfNull: false,
  )


  final String? authTenant;



  @JsonKey(
    
    name: r'hasAuth',
    required: true,
    includeIfNull: false,
  )


  final bool hasAuth;



  @JsonKey(
    
    name: r'caPem',
    required: true,
    includeIfNull: false,
  )


  final String caPem;



  @JsonKey(
    
    name: r'scope',
    required: true,
    includeIfNull: false,
  )


  final LogScope scope;



  @JsonKey(
    
    name: r'fields',
    required: true,
    includeIfNull: false,
  )


  final LogFields fields;



  @JsonKey(
    
    name: r'pollSeconds',
    required: true,
    includeIfNull: false,
  )


  final int pollSeconds;



  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final LogSourceStatusEnum status;



  @JsonKey(
    
    name: r'lastError',
    required: true,
    includeIfNull: false,
  )


  final String lastError;



  @JsonKey(
    
    name: r'lastReadAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastReadAt;



      /// Start of a range not read after a long outage
  @JsonKey(
    
    name: r'gapFrom',
    required: false,
    includeIfNull: false,
  )


  final DateTime? gapFrom;



  @JsonKey(
    
    name: r'gapTo',
    required: false,
    includeIfNull: false,
  )


  final DateTime? gapTo;



      /// Entries skipped over the per-minute cap
  @JsonKey(
    
    name: r'dropped',
    required: true,
    includeIfNull: false,
  )


  final int dropped;



      /// The private network the last read went through
  @JsonKey(
    
    name: r'networkId',
    required: false,
    includeIfNull: false,
  )


  final int? networkId;



  @JsonKey(
    
    name: r'hasPushToken',
    required: true,
    includeIfNull: false,
  )


  final bool hasPushToken;



      /// Where a push source's shipper sends
  @JsonKey(
    
    name: r'pushUrl',
    required: false,
    includeIfNull: false,
  )


  final String? pushUrl;



  @JsonKey(
    
    name: r'services',
    required: true,
    includeIfNull: false,
  )


  final List<LogService> services;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogSource &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.environment == environment &&
      other.address == address &&
      other.authKind == authKind &&
      other.authUser == authUser &&
      other.authTenant == authTenant &&
      other.hasAuth == hasAuth &&
      other.caPem == caPem &&
      other.scope == scope &&
      other.fields == fields &&
      other.pollSeconds == pollSeconds &&
      other.enabled == enabled &&
      other.status == status &&
      other.lastError == lastError &&
      other.lastReadAt == lastReadAt &&
      other.gapFrom == gapFrom &&
      other.gapTo == gapTo &&
      other.dropped == dropped &&
      other.networkId == networkId &&
      other.hasPushToken == hasPushToken &&
      other.pushUrl == pushUrl &&
      other.services == services &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        kind.hashCode +
        environment.hashCode +
        address.hashCode +
        authKind.hashCode +
        authUser.hashCode +
        authTenant.hashCode +
        hasAuth.hashCode +
        caPem.hashCode +
        scope.hashCode +
        fields.hashCode +
        pollSeconds.hashCode +
        enabled.hashCode +
        status.hashCode +
        lastError.hashCode +
        lastReadAt.hashCode +
        gapFrom.hashCode +
        gapTo.hashCode +
        dropped.hashCode +
        networkId.hashCode +
        hasPushToken.hashCode +
        pushUrl.hashCode +
        services.hashCode +
        createdAt.hashCode;

  factory LogSource.fromJson(Map<String, dynamic> json) => _$LogSourceFromJson(json);

  Map<String, dynamic> toJson() => _$LogSourceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum LogSourceKindEnum {
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

const LogSourceKindEnum(this.value);

final String value;

@override
String toString() => value;
}


enum LogSourceStatusEnum {
@JsonValue(r'new')
new_(r'new'),
@JsonValue(r'ok')
ok(r'ok'),
@JsonValue(r'behind')
behind(r'behind'),
@JsonValue(r'failing')
failing(r'failing'),
@JsonValue(r'auth_failed')
authFailed(r'auth_failed');

const LogSourceStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


