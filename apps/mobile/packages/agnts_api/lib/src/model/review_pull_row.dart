//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/pull_item.dart';
import 'package:agnts_api/src/model/pull_review_ref.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_pull_row.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewPullRow {
  /// Returns a new [ReviewPullRow] instance.
  ReviewPullRow({

    required  this.repoId,

    required  this.repoName,

    required  this.provider,

    required  this.pull,

     this.review,
  });

  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;



  @JsonKey(
    
    name: r'repoName',
    required: true,
    includeIfNull: false,
  )


  final String repoName;



  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final ReviewPullRowProviderEnum provider;



  @JsonKey(
    
    name: r'pull',
    required: true,
    includeIfNull: false,
  )


  final PullItem pull;



  @JsonKey(
    
    name: r'review',
    required: false,
    includeIfNull: false,
  )


  final PullReviewRef? review;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewPullRow &&
      other.repoId == repoId &&
      other.repoName == repoName &&
      other.provider == provider &&
      other.pull == pull &&
      other.review == review;

    @override
    int get hashCode =>
        repoId.hashCode +
        repoName.hashCode +
        provider.hashCode +
        pull.hashCode +
        review.hashCode;

  factory ReviewPullRow.fromJson(Map<String, dynamic> json) => _$ReviewPullRowFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewPullRowToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ReviewPullRowProviderEnum {
@JsonValue(r'github')
github(r'github'),
@JsonValue(r'gitlab')
gitlab(r'gitlab');

const ReviewPullRowProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


