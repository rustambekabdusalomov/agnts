//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_meeting_cohosts_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetMeetingCohostsRequest {
  /// Returns a new [SetMeetingCohostsRequest] instance.
  SetMeetingCohostsRequest({

    required  this.userIds,
  });

  @JsonKey(
    
    name: r'userIds',
    required: true,
    includeIfNull: false,
  )


  final List<int> userIds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetMeetingCohostsRequest &&
      other.userIds == userIds;

    @override
    int get hashCode =>
        userIds.hashCode;

  factory SetMeetingCohostsRequest.fromJson(Map<String, dynamic> json) => _$SetMeetingCohostsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetMeetingCohostsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

