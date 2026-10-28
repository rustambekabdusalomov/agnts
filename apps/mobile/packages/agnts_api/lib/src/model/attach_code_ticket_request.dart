//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attach_code_ticket_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AttachCodeTicketRequest {
  /// Returns a new [AttachCodeTicketRequest] instance.
  AttachCodeTicketRequest({

    required  this.key,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AttachCodeTicketRequest &&
      other.key == key;

    @override
    int get hashCode =>
        key.hashCode;

  factory AttachCodeTicketRequest.fromJson(Map<String, dynamic> json) => _$AttachCodeTicketRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AttachCodeTicketRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

