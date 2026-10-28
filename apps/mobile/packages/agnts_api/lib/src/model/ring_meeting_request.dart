//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ring_meeting_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RingMeetingRequest {
  /// Returns a new [RingMeetingRequest] instance.
  RingMeetingRequest({

    required  this.userIds,
  });

  @JsonKey(
    
    name: r'userIds',
    required: true,
    includeIfNull: false,
  )


  final List<int> userIds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RingMeetingRequest &&
      other.userIds == userIds;

    @override
    int get hashCode =>
        userIds.hashCode;

  factory RingMeetingRequest.fromJson(Map<String, dynamic> json) => _$RingMeetingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RingMeetingRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

