//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_review_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PostReviewInput {
  /// Returns a new [PostReviewInput] instance.
  PostReviewInput({

     this.summary = true,

     this.findings,

     this.requestChanges,
  });

      /// Post the summary (verdict and every finding)
  @JsonKey(
    defaultValue: true,
    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final bool? summary;



      /// Indexes of the findings to post on their lines; left out, every finding on a line of the diff
  @JsonKey(
    
    name: r'findings',
    required: false,
    includeIfNull: false,
  )


  final List<int>? findings;



      /// Post it as a request for changes (GitHub)
  @JsonKey(
    
    name: r'requestChanges',
    required: false,
    includeIfNull: false,
  )


  final bool? requestChanges;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PostReviewInput &&
      other.summary == summary &&
      other.findings == findings &&
      other.requestChanges == requestChanges;

    @override
    int get hashCode =>
        summary.hashCode +
        findings.hashCode +
        requestChanges.hashCode;

  factory PostReviewInput.fromJson(Map<String, dynamic> json) => _$PostReviewInputFromJson(json);

  Map<String, dynamic> toJson() => _$PostReviewInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

