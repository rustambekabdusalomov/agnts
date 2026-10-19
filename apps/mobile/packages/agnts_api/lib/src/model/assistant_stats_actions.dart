//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_stats_actions.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantStatsActions {
  /// Returns a new [AssistantStatsActions] instance.
  AssistantStatsActions({

    required  this.proposed,

    required  this.done,

    required  this.failed,

    required  this.cancelled,

    required  this.expired,

    required  this.notOffered,
  });

  @JsonKey(
    
    name: r'proposed',
    required: true,
    includeIfNull: false,
  )


  final int proposed;



  @JsonKey(
    
    name: r'done',
    required: true,
    includeIfNull: false,
  )


  final int done;



  @JsonKey(
    
    name: r'failed',
    required: true,
    includeIfNull: false,
  )


  final int failed;



      /// Declined by the person
  @JsonKey(
    
    name: r'cancelled',
    required: true,
    includeIfNull: false,
  )


  final int cancelled;



  @JsonKey(
    
    name: r'expired',
    required: true,
    includeIfNull: false,
  )


  final int expired;



      /// Proposals that failed agnts's checks
  @JsonKey(
    
    name: r'notOffered',
    required: true,
    includeIfNull: false,
  )


  final int notOffered;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantStatsActions &&
      other.proposed == proposed &&
      other.done == done &&
      other.failed == failed &&
      other.cancelled == cancelled &&
      other.expired == expired &&
      other.notOffered == notOffered;

    @override
    int get hashCode =>
        proposed.hashCode +
        done.hashCode +
        failed.hashCode +
        cancelled.hashCode +
        expired.hashCode +
        notOffered.hashCode;

  factory AssistantStatsActions.fromJson(Map<String, dynamic> json) => _$AssistantStatsActionsFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantStatsActionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

