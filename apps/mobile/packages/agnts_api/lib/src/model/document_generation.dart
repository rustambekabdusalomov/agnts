//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document_source_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_generation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentGeneration {
  /// Returns a new [DocumentGeneration] instance.
  DocumentGeneration({

    required  this.id,

    required  this.status,

    required  this.error,

     this.source_,

     this.requestedBy,

     this.startedAt,

     this.finishedAt,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final DocumentGenerationStatusEnum status;



  @JsonKey(
    
    name: r'error',
    required: true,
    includeIfNull: false,
  )


  final String error;



  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final DocumentSourceInput? source_;



  @JsonKey(
    
    name: r'requestedBy',
    required: false,
    includeIfNull: false,
  )


  final int? requestedBy;



  @JsonKey(
    
    name: r'startedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? startedAt;



  @JsonKey(
    
    name: r'finishedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? finishedAt;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentGeneration &&
      other.id == id &&
      other.status == status &&
      other.error == error &&
      other.source_ == source_ &&
      other.requestedBy == requestedBy &&
      other.startedAt == startedAt &&
      other.finishedAt == finishedAt &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        status.hashCode +
        error.hashCode +
        source_.hashCode +
        requestedBy.hashCode +
        startedAt.hashCode +
        finishedAt.hashCode +
        createdAt.hashCode;

  factory DocumentGeneration.fromJson(Map<String, dynamic> json) => _$DocumentGenerationFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentGenerationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentGenerationStatusEnum {
@JsonValue(r'queued')
queued(r'queued'),
@JsonValue(r'writing')
writing(r'writing'),
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'failed')
failed(r'failed');

const DocumentGenerationStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


