//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_review_draft_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateReviewDraftRequest {
  /// Returns a new [UpdateReviewDraftRequest] instance.
  UpdateReviewDraftRequest({

     this.state,

     this.body,

     this.dismissReason,
  });

  @JsonKey(
    
    name: r'state',
    required: false,
    includeIfNull: false,
  )


  final UpdateReviewDraftRequestStateEnum? state;



  @JsonKey(
    
    name: r'body',
    required: false,
    includeIfNull: false,
  )


  final String? body;



      /// Why it was dismissed: teaches agnts what you call noise
  @JsonKey(
    
    name: r'dismissReason',
    required: false,
    includeIfNull: false,
  )


  final String? dismissReason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateReviewDraftRequest &&
      other.state == state &&
      other.body == body &&
      other.dismissReason == dismissReason;

    @override
    int get hashCode =>
        state.hashCode +
        body.hashCode +
        dismissReason.hashCode;

  factory UpdateReviewDraftRequest.fromJson(Map<String, dynamic> json) => _$UpdateReviewDraftRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateReviewDraftRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum UpdateReviewDraftRequestStateEnum {
@JsonValue(r'draft')
draft(r'draft'),
@JsonValue(r'accepted')
accepted(r'accepted'),
@JsonValue(r'dismissed')
dismissed(r'dismissed');

const UpdateReviewDraftRequestStateEnum(this.value);

final String value;

@override
String toString() => value;
}


