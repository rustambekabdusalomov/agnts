//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
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
  });

  @JsonKey(
    
    name: r'feedback',
    required: true,
    includeIfNull: false,
  )


  final String feedback;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RequestChangesRequest &&
      other.feedback == feedback;

    @override
    int get hashCode =>
        feedback.hashCode;

  factory RequestChangesRequest.fromJson(Map<String, dynamic> json) => _$RequestChangesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestChangesRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

