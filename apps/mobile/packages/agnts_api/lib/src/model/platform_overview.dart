//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/platform_overview_runs_inner.dart';
import 'package:agnts_api/src/model/capacity.dart';
import 'package:agnts_api/src/model/platform_overview_server_queue_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'platform_overview.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformOverview {
  /// Returns a new [PlatformOverview] instance.
  PlatformOverview({

    required  this.capacity,

    required  this.runs,

    required  this.serverQueue,

    required  this.workspaces,

    required  this.users,
  });

  @JsonKey(
    
    name: r'capacity',
    required: true,
    includeIfNull: false,
  )


  final Capacity capacity;



  @JsonKey(
    
    name: r'runs',
    required: true,
    includeIfNull: false,
  )


  final List<PlatformOverviewRunsInner> runs;



  @JsonKey(
    
    name: r'serverQueue',
    required: true,
    includeIfNull: false,
  )


  final List<PlatformOverviewServerQueueInner> serverQueue;



  @JsonKey(
    
    name: r'workspaces',
    required: true,
    includeIfNull: false,
  )


  final int workspaces;



  @JsonKey(
    
    name: r'users',
    required: true,
    includeIfNull: false,
  )


  final int users;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformOverview &&
      other.capacity == capacity &&
      other.runs == runs &&
      other.serverQueue == serverQueue &&
      other.workspaces == workspaces &&
      other.users == users;

    @override
    int get hashCode =>
        capacity.hashCode +
        runs.hashCode +
        serverQueue.hashCode +
        workspaces.hashCode +
        users.hashCode;

  factory PlatformOverview.fromJson(Map<String, dynamic> json) => _$PlatformOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformOverviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

