//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'publish_review_drafts_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublishReviewDraftsRequest {
  /// Returns a new [PublishReviewDraftsRequest] instance.
  PublishReviewDraftsRequest({

     this.requestChanges,
  });

      /// Publish it as a request for changes (GitHub)
  @JsonKey(
    
    name: r'requestChanges',
    required: false,
    includeIfNull: false,
  )


  final bool? requestChanges;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublishReviewDraftsRequest &&
      other.requestChanges == requestChanges;

    @override
    int get hashCode =>
        requestChanges.hashCode;

  factory PublishReviewDraftsRequest.fromJson(Map<String, dynamic> json) => _$PublishReviewDraftsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PublishReviewDraftsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

