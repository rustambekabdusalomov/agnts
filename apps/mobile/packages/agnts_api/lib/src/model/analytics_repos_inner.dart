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

