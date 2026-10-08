//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'platform_overview_server_queue_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformOverviewServerQueueInner {
  /// Returns a new [PlatformOverviewServerQueueInner] instance.
  PlatformOverviewServerQueueInner({

    required  this.workspaceId,

     this.workspace,

    required  this.ticketKey,
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformOverviewServerQueueInner &&
      other.workspaceId == workspaceId &&
      other.workspace == workspace &&
      other.ticketKey == ticketKey;

    @override
    int get hashCode =>
        workspaceId.hashCode +
        workspace.hashCode +
        ticketKey.hashCode;

  factory PlatformOverviewServerQueueInner.fromJson(Map<String, dynamic> json) => _$PlatformOverviewServerQueueInnerFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformOverviewServerQueueInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

