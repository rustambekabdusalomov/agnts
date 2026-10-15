//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accept_all_review_drafts_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AcceptAllReviewDraftsRequest {
  /// Returns a new [AcceptAllReviewDraftsRequest] instance.
  AcceptAllReviewDraftsRequest({

     this.minSeverity,
  });

  @JsonKey(
    
    name: r'minSeverity',
    required: false,
    includeIfNull: false,
  )


  final AcceptAllReviewDraftsRequestMinSeverityEnum? minSeverity;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AcceptAllReviewDraftsRequest &&
      other.minSeverity == minSeverity;

    @override
    int get hashCode =>
        minSeverity.hashCode;

  factory AcceptAllReviewDraftsRequest.fromJson(Map<String, dynamic> json) => _$AcceptAllReviewDraftsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptAllReviewDraftsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AcceptAllReviewDraftsRequestMinSeverityEnum {
@JsonValue(r'blocker')
blocker(r'blocker'),
@JsonValue(r'major')
major(r'major'),
@JsonValue(r'minor')
minor(r'minor'),
@JsonValue(r'nit')
nit(r'nit');

const AcceptAllReviewDraftsRequestMinSeverityEnum(this.value);

final String value;

@override
String toString() => value;
}


