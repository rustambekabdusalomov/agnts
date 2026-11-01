//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_occurrence.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogOccurrence {
  /// Returns a new [LogOccurrence] instance.
  LogOccurrence({

    required  this.at,

    required  this.sourceId,

    required  this.service,

     this.revision,

    required  this.count,
  });

  @JsonKey(
    
    name: r'at',
    required: true,
    includeIfNull: false,
  )


  final DateTime at;



  @JsonKey(
    
    name: r'sourceId',
    required: true,
    includeIfNull: false,
  )


  final int sourceId;



  @JsonKey(
    
    name: r'service',
    required: true,
    includeIfNull: false,
  )


  final String service;



  @JsonKey(
    
    name: r'revision',
    required: false,
    includeIfNull: false,
  )


  final String? revision;



  @JsonKey(
    
    name: r'count',
    required: true,
    includeIfNull: false,
  )


  final int count;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogOccurrence &&
      other.at == at &&
      other.sourceId == sourceId &&
      other.service == service &&
      other.revision == revision &&
      other.count == count;

    @override
    int get hashCode =>
        at.hashCode +
        sourceId.hashCode +
        service.hashCode +
        revision.hashCode +
        count.hashCode;

  factory LogOccurrence.fromJson(Map<String, dynamic> json) => _$LogOccurrenceFromJson(json);

  Map<String, dynamic> toJson() => _$LogOccurrenceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

