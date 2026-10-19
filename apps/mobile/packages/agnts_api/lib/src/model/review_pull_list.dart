//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/review_pull_row.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_pull_list.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewPullList {
  /// Returns a new [ReviewPullList] instance.
  ReviewPullList({

    required  this.pulls,

    required  this.errors,
  });

  @JsonKey(
    
    name: r'pulls',
    required: true,
    includeIfNull: false,
  )


  final List<ReviewPullRow> pulls;



      /// Repositories the git host did not answer for
  @JsonKey(
    
    name: r'errors',
    required: true,
    includeIfNull: false,
  )


  final List<String> errors;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewPullList &&
      other.pulls == pulls &&
      other.errors == errors;

    @override
    int get hashCode =>
        pulls.hashCode +
        errors.hashCode;

  factory ReviewPullList.fromJson(Map<String, dynamic> json) => _$ReviewPullListFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewPullListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

