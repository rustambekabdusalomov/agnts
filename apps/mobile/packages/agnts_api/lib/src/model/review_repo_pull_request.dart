//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_repo_pull_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewRepoPullRequest {
  /// Returns a new [ReviewRepoPullRequest] instance.
  ReviewRepoPullRequest({

     this.focus,

     this.deep,
  });

      /// What the review should look at especially
  @JsonKey(
    
    name: r'focus',
    required: false,
    includeIfNull: false,
  )


  final String? focus;



      /// Deep review (specialist passes): '' follows the workspace setting
  @JsonKey(
    
    name: r'deep',
    required: false,
    includeIfNull: false,
  )


  final ReviewRepoPullRequestDeepEnum? deep;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewRepoPullRequest &&
      other.focus == focus &&
      other.deep == deep;

    @override
    int get hashCode =>
        focus.hashCode +
        deep.hashCode;

  factory ReviewRepoPullRequest.fromJson(Map<String, dynamic> json) => _$ReviewRepoPullRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewRepoPullRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Deep review (specialist passes): '' follows the workspace setting
enum ReviewRepoPullRequestDeepEnum {
@JsonValue(r'')
empty(r''),
@JsonValue(r'off')
off(r'off'),
@JsonValue(r'always')
always(r'always');

const ReviewRepoPullRequestDeepEnum(this.value);

final String value;

@override
String toString() => value;
}


