//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reject_ticket_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RejectTicketRequest {
  /// Returns a new [RejectTicketRequest] instance.
  RejectTicketRequest({

     this.reason,
  });

  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RejectTicketRequest &&
      other.reason == reason;

    @override
    int get hashCode =>
        reason.hashCode;

  factory RejectTicketRequest.fromJson(Map<String, dynamic> json) => _$RejectTicketRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RejectTicketRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

