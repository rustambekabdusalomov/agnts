//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_counts.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardCounts {
  /// Returns a new [DashboardCounts] instance.
  DashboardCounts({

    required  this.needs,

    required  this.answers,

    required  this.reviews,

    required  this.stopped,

    required  this.running,

    required  this.queued,
  });

  @JsonKey(
    
    name: r'needs',
    required: true,
    includeIfNull: false,
  )


  final int needs;



  @JsonKey(
    
    name: r'answers',
    required: true,
    includeIfNull: false,
  )


  final int answers;



  @JsonKey(
    
    name: r'reviews',
    required: true,
    includeIfNull: false,
  )


  final int reviews;



  @JsonKey(
    
    name: r'stopped',
    required: true,
    includeIfNull: false,
  )


  final int stopped;



  @JsonKey(
    
    name: r'running',
    required: true,
    includeIfNull: false,
  )


  final int running;



  @JsonKey(
    
    name: r'queued',
    required: true,
    includeIfNull: false,
  )


  final int queued;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DashboardCounts &&
      other.needs == needs &&
      other.answers == answers &&
      other.reviews == reviews &&
      other.stopped == stopped &&
      other.running == running &&
      other.queued == queued;

    @override
    int get hashCode =>
        needs.hashCode +
        answers.hashCode +
        reviews.hashCode +
        stopped.hashCode +
        running.hashCode +
        queued.hashCode;

  factory DashboardCounts.fromJson(Map<String, dynamic> json) => _$DashboardCountsFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardCountsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

