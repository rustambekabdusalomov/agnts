//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'add_review_draft_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AddReviewDraftRequest {
  /// Returns a new [AddReviewDraftRequest] instance.
  AddReviewDraftRequest({

    required  this.body,

     this.path,

     this.line,

     this.headSha,
  });

  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



  @JsonKey(
    
    name: r'path',
    required: false,
    includeIfNull: false,
  )


  final String? path;



      /// Line in the new file
          // minimum: 0
  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



      /// The commit the line is in; the newest when empty
  @JsonKey(
    
    name: r'headSha',
    required: false,
    includeIfNull: false,
  )


  final String? headSha;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AddReviewDraftRequest &&
      other.body == body &&
      other.path == path &&
      other.line == line &&
      other.headSha == headSha;

    @override
    int get hashCode =>
        body.hashCode +
        path.hashCode +
        line.hashCode +
        headSha.hashCode;

  factory AddReviewDraftRequest.fromJson(Map<String, dynamic> json) => _$AddReviewDraftRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddReviewDraftRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

