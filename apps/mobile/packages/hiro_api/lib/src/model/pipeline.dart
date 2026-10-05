//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/ci.dart';
import 'package:hiro_api/src/model/stage.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pipeline.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Pipeline {
  /// Returns a new [Pipeline] instance.
  Pipeline({

    required  this.id,

    required  this.name,

    required  this.branch,

    required  this.sha,

    required  this.message,

    required  this.trigger,

    required  this.status,

     this.created,

    required  this.durationMs,

    required  this.url,

    required  this.stages,
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
    
    name: r'branch',
    required: true,
    includeIfNull: false,
  )


  final String branch;



  @JsonKey(
    
    name: r'sha',
    required: true,
    includeIfNull: false,
  )


  final String sha;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'trigger',
    required: true,
    includeIfNull: false,
  )


  final String trigger;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CI status;



  @JsonKey(
    
    name: r'created',
    required: false,
    includeIfNull: false,
  )


  final DateTime? created;



  @JsonKey(
    
    name: r'durationMs',
    required: true,
    includeIfNull: false,
  )


  final int durationMs;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'stages',
    required: true,
    includeIfNull: false,
  )


  final List<Stage> stages;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Pipeline &&
      other.id == id &&
      other.name == name &&
      other.branch == branch &&
      other.sha == sha &&
      other.message == message &&
      other.trigger == trigger &&
      other.status == status &&
      other.created == created &&
      other.durationMs == durationMs &&
      other.url == url &&
      other.stages == stages;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        branch.hashCode +
        sha.hashCode +
        message.hashCode +
        trigger.hashCode +
        status.hashCode +
        created.hashCode +
        durationMs.hashCode +
        url.hashCode +
        stages.hashCode;

  factory Pipeline.fromJson(Map<String, dynamic> json) => _$PipelineFromJson(json);

  Map<String, dynamic> toJson() => _$PipelineToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

