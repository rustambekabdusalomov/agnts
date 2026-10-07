//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/shot_ref.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'request_changes_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RequestChangesRequest {
  /// Returns a new [RequestChangesRequest] instance.
  RequestChangesRequest({

    required  this.feedback,

     this.shots,

     this.attachments,
  });

  @JsonKey(
    
    name: r'feedback',
    required: true,
    includeIfNull: false,
  )


  final String feedback;



      /// Preview screenshots the feedback points at; the coding run gets them
  @JsonKey(
    
    name: r'shots',
    required: false,
    includeIfNull: false,
  )


  final List<ShotRef>? shots;



      /// Uploads that go with the feedback (mockups, logs, screenshots); the coding run reads them
  @JsonKey(
    
    name: r'attachments',
    required: false,
    includeIfNull: false,
  )


  final List<int>? attachments;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RequestChangesRequest &&
      other.feedback == feedback &&
      other.shots == shots &&
      other.attachments == attachments;

    @override
    int get hashCode =>
        feedback.hashCode +
        shots.hashCode +
        attachments.hashCode;

  factory RequestChangesRequest.fromJson(Map<String, dynamic> json) => _$RequestChangesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestChangesRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

