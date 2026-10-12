//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reviewer_stat.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewerStat {
  /// Returns a new [ReviewerStat] instance.
  ReviewerStat({

    required  this.login,

    required  this.rereview,

    required  this.dismissed,

    required  this.manual,

    required  this.repos,
  });

  @JsonKey(
    
    name: r'login',
    required: true,
    includeIfNull: false,
  )


  final String login;



  @JsonKey(
    
    name: r'rereview',
    required: true,
    includeIfNull: false,
  )


  final int rereview;



  @JsonKey(
    
    name: r'dismissed',
    required: true,
    includeIfNull: false,
  )


  final int dismissed;



  @JsonKey(
    
    name: r'manual',
    required: true,
    includeIfNull: false,
  )


  final int manual;



  @JsonKey(
    
    name: r'repos',
    required: true,
    includeIfNull: false,
  )


  final List<String> repos;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewerStat &&
      other.login == login &&
      other.rereview == rereview &&
      other.dismissed == dismissed &&
      other.manual == manual &&
      other.repos == repos;

    @override
    int get hashCode =>
        login.hashCode +
        rereview.hashCode +
        dismissed.hashCode +
        manual.hashCode +
        repos.hashCode;

  factory ReviewerStat.fromJson(Map<String, dynamic> json) => _$ReviewerStatFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewerStatToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

