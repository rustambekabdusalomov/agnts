//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_fields.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogFields {
  /// Returns a new [LogFields] instance.
  LogFields({

     this.message,

     this.timestamp,

     this.level,

     this.service,

     this.revision,

     this.traceUrl,
  });

  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;



  @JsonKey(
    
    name: r'timestamp',
    required: false,
    includeIfNull: false,
  )


  final String? timestamp;



  @JsonKey(
    
    name: r'level',
    required: false,
    includeIfNull: false,
  )


  final String? level;



  @JsonKey(
    
    name: r'service',
    required: false,
    includeIfNull: false,
  )


  final String? service;



  @JsonKey(
    
    name: r'revision',
    required: false,
    includeIfNull: false,
  )


  final String? revision;



      /// Link to a trace in the tracing UI (Tempo, Jaeger), with {traceId} where the id goes
  @JsonKey(
    
    name: r'traceUrl',
    required: false,
    includeIfNull: false,
  )


  final String? traceUrl;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogFields &&
      other.message == message &&
      other.timestamp == timestamp &&
      other.level == level &&
      other.service == service &&
      other.revision == revision &&
      other.traceUrl == traceUrl;

    @override
    int get hashCode =>
        message.hashCode +
        timestamp.hashCode +
        level.hashCode +
        service.hashCode +
        revision.hashCode +
        traceUrl.hashCode;

  factory LogFields.fromJson(Map<String, dynamic> json) => _$LogFieldsFromJson(json);

  Map<String, dynamic> toJson() => _$LogFieldsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

