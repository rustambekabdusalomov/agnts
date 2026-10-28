//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_ticket_chat200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GetTicketChat200Response {
  /// Returns a new [GetTicketChat200Response] instance.
  GetTicketChat200Response({

    required  this.conversationId,
  });

  @JsonKey(
    
    name: r'conversationId',
    required: true,
    includeIfNull: false,
  )


  final int conversationId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GetTicketChat200Response &&
      other.conversationId == conversationId;

    @override
    int get hashCode =>
        conversationId.hashCode;

  factory GetTicketChat200Response.fromJson(Map<String, dynamic> json) => _$GetTicketChat200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetTicketChat200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

