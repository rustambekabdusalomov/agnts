//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/ticket_kind_choice.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ticket_kind_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TicketKindInput {
  /// Returns a new [TicketKindInput] instance.
  TicketKindInput({

    required  this.kind,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final TicketKindChoice kind;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TicketKindInput &&
      other.kind == kind;

    @override
    int get hashCode =>
        kind.hashCode;

  factory TicketKindInput.fromJson(Map<String, dynamic> json) => _$TicketKindInputFromJson(json);

  Map<String, dynamic> toJson() => _$TicketKindInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

