//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_platform_feedback_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdatePlatformFeedbackRequest {
  /// Returns a new [UpdatePlatformFeedbackRequest] instance.
  UpdatePlatformFeedbackRequest({

    required  this.status,
  });

  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final UpdatePlatformFeedbackRequestStatusEnum status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdatePlatformFeedbackRequest &&
      other.status == status;

    @override
    int get hashCode =>
        status.hashCode;

  factory UpdatePlatformFeedbackRequest.fromJson(Map<String, dynamic> json) => _$UpdatePlatformFeedbackRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePlatformFeedbackRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum UpdatePlatformFeedbackRequestStatusEnum {
@JsonValue(r'new')
new_(r'new'),
@JsonValue(r'done')
done(r'done');

const UpdatePlatformFeedbackRequestStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


