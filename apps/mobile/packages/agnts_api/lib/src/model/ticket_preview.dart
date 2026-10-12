//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/preview_issue.dart';
import 'package:agnts_api/src/model/acceptance.dart';
import 'package:agnts_api/src/model/preview_shot.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ticket_preview.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TicketPreview {
  /// Returns a new [TicketPreview] instance.
  TicketPreview({

    required  this.runId,

    required  this.revision,

    required  this.model,

    required  this.compare,

    required  this.status,

    required  this.summary,

    required  this.shots,

    required  this.issues,

     this.acceptance,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'runId',
    required: true,
    includeIfNull: false,
  )


  final int runId;



  @JsonKey(
    
    name: r'revision',
    required: true,
    includeIfNull: false,
  )


  final int revision;



      /// A Claude model (haiku, sonnet, opus), or codex:<model> for a run on Codex CLI
  @JsonKey(
    
    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final String model;



      /// Before shots were taken too
  @JsonKey(
    
    name: r'compare',
    required: true,
    includeIfNull: false,
  )


  final bool compare;



      /// failed: the app did not start
  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final TicketPreviewStatusEnum status;



  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final String summary;



  @JsonKey(
    
    name: r'shots',
    required: true,
    includeIfNull: false,
  )


  final List<PreviewShot> shots;



  @JsonKey(
    
    name: r'issues',
    required: true,
    includeIfNull: false,
  )


  final List<PreviewIssue> issues;



  @JsonKey(
    
    name: r'acceptance',
    required: false,
    includeIfNull: false,
  )


  final Acceptance? acceptance;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TicketPreview &&
      other.runId == runId &&
      other.revision == revision &&
      other.model == model &&
      other.compare == compare &&
      other.status == status &&
      other.summary == summary &&
      other.shots == shots &&
      other.issues == issues &&
      other.acceptance == acceptance &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        runId.hashCode +
        revision.hashCode +
        model.hashCode +
        compare.hashCode +
        status.hashCode +
        summary.hashCode +
        shots.hashCode +
        issues.hashCode +
        acceptance.hashCode +
        createdAt.hashCode;

  factory TicketPreview.fromJson(Map<String, dynamic> json) => _$TicketPreviewFromJson(json);

  Map<String, dynamic> toJson() => _$TicketPreviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// failed: the app did not start
enum TicketPreviewStatusEnum {
@JsonValue(r'ok')
ok(r'ok'),
@JsonValue(r'partial')
partial(r'partial'),
@JsonValue(r'failed')
failed(r'failed');

const TicketPreviewStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


