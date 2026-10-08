//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'platform_overview_runs_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformOverviewRunsInner {
  /// Returns a new [PlatformOverviewRunsInner] instance.
  PlatformOverviewRunsInner({

    required  this.workspaceId,

     this.workspace,

    required  this.ticketKey,

    required  this.stage,

    required  this.startedAt,
  });

  @JsonKey(
    
    name: r'workspaceId',
    required: true,
    includeIfNull: false,
  )


  final int workspaceId;



  @JsonKey(
    
    name: r'workspace',
    required: false,
    includeIfNull: false,
  )


  final String? workspace;



  @JsonKey(
    
    name: r'ticketKey',
    required: true,
    includeIfNull: false,
  )


  final String ticketKey;



  @JsonKey(
    
    name: r'stage',
    required: true,
    includeIfNull: false,
  )


  final String stage;



  @JsonKey(
    
    name: r'startedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime startedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformOverviewRunsInner &&
      other.workspaceId == workspaceId &&
      other.workspace == workspace &&
      other.ticketKey == ticketKey &&
      other.stage == stage &&
      other.startedAt == startedAt;

    @override
    int get hashCode =>
        workspaceId.hashCode +
        workspace.hashCode +
        ticketKey.hashCode +
        stage.hashCode +
        startedAt.hashCode;

  factory PlatformOverviewRunsInner.fromJson(Map<String, dynamic> json) => _$PlatformOverviewRunsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformOverviewRunsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

