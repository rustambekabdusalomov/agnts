//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_ticket_member_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetTicketMemberRequest {
  /// Returns a new [SetTicketMemberRequest] instance.
  SetTicketMemberRequest({

    required  this.userId,
  });

      /// A member of the workspace; 0 for yourself
  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final int userId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetTicketMemberRequest &&
      other.userId == userId;

    @override
    int get hashCode =>
        userId.hashCode;

  factory SetTicketMemberRequest.fromJson(Map<String, dynamic> json) => _$SetTicketMemberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetTicketMemberRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

