//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics_repos_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalyticsReposInner {
  /// Returns a new [AnalyticsReposInner] instance.
  AnalyticsReposInner({

    required  this.merged,

    required  this.closed,

    required  this.asked,

    required  this.analyzed,

    required  this.ciFailures,

    required  this.repoId,

    required  this.name,

    required  this.kind,

    required  this.claudeMd,

    required  this.tickets,

    required  this.done,

    required  this.finished,

    required  this.avgTurns,

    required  this.agntsMin,
  });

      /// Pull requests merged in the period
  @JsonKey(
    
    name: r'merged',
    required: true,
    includeIfNull: false,
  )


  final int merged;



      /// Pull requests closed without a merge in the period
  @JsonKey(
    
    name: r'closed',
    required: true,
    includeIfNull: false,
  )


  final int closed;



      /// Questions agnts asked in the period
  @JsonKey(
    
    name: r'asked',
    required: true,
    includeIfNull: false,
  )


  final int asked;



      /// Tickets analysed in the period
  @JsonKey(
    
    name: r'analyzed',
    required: true,
    includeIfNull: false,
  )


  final int analyzed;



      /// CI failure groups that failed in the period
  @JsonKey(
    
    name: r'ciFailures',
    required: true,
    includeIfNull: false,
  )


  final int ciFailures;



  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final String kind;



  @JsonKey(
    
    name: r'claudeMd',
    required: true,
    includeIfNull: false,
  )


  final String claudeMd;



  @JsonKey(
    
    name: r'tickets',
    required: true,
    includeIfNull: false,
  )


  final int tickets;



  @JsonKey(
    
    name: r'done',
    required: true,
    includeIfNull: false,
  )


  final int done;



  @JsonKey(
    
    name: r'finished',
    required: true,
    includeIfNull: false,
  )


  final int finished;



  @JsonKey(
    
    name: r'avgTurns',
    required: true,
    includeIfNull: false,
  )


  final num avgTurns;



  @JsonKey(
    
    name: r'agntsMin',
    required: true,
    includeIfNull: false,
  )


  final num agntsMin;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalyticsReposInner &&
      other.merged == merged &&
      other.closed == closed &&
      other.asked == asked &&
      other.analyzed == analyzed &&
      other.ciFailures == ciFailures &&
      other.repoId == repoId &&
      other.name == name &&
      other.kind == kind &&
      other.claudeMd == claudeMd &&
      other.tickets == tickets &&
      other.done == done &&
      other.finished == finished &&
      other.avgTurns == avgTurns &&
      other.agntsMin == agntsMin;

    @override
    int get hashCode =>
        merged.hashCode +
        closed.hashCode +
        asked.hashCode +
        analyzed.hashCode +
        ciFailures.hashCode +
        repoId.hashCode +
        name.hashCode +
        kind.hashCode +
        claudeMd.hashCode +
        tickets.hashCode +
        done.hashCode +
        finished.hashCode +
        avgTurns.hashCode +
        agntsMin.hashCode;

  factory AnalyticsReposInner.fromJson(Map<String, dynamic> json) => _$AnalyticsReposInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsReposInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

