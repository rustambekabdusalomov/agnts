//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_ticket_number_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetTicketNumberRequest {
  /// Returns a new [SetTicketNumberRequest] instance.
  SetTicketNumberRequest({

    required  this.number,
  });

  @JsonKey(
    
    name: r'number',
    required: true,
    includeIfNull: false,
  )


  final String number;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetTicketNumberRequest &&
      other.number == number;

    @override
    int get hashCode =>
        number.hashCode;

  factory SetTicketNumberRequest.fromJson(Map<String, dynamic> json) => _$SetTicketNumberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetTicketNumberRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

