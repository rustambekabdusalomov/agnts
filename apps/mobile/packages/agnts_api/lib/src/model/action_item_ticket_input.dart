//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'action_item_ticket_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActionItemTicketInput {
  /// Returns a new [ActionItemTicketInput] instance.
  ActionItemTicketInput({

     this.repoId,

     this.start,
  });

      /// The repository; absent lets agnts pick, or none
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



      /// ask when absent
  @JsonKey(
    
    name: r'start',
    required: false,
    includeIfNull: false,
  )


  final ActionItemTicketInputStartEnum? start;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActionItemTicketInput &&
      other.repoId == repoId &&
      other.start == start;

    @override
    int get hashCode =>
        repoId.hashCode +
        start.hashCode;

  factory ActionItemTicketInput.fromJson(Map<String, dynamic> json) => _$ActionItemTicketInputFromJson(json);

  Map<String, dynamic> toJson() => _$ActionItemTicketInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// ask when absent
enum ActionItemTicketInputStartEnum {
@JsonValue(r'ask')
ask(r'ask'),
@JsonValue(r'code')
code(r'code'),
@JsonValue(r'queue')
queue(r'queue');

const ActionItemTicketInputStartEnum(this.value);

final String value;

@override
String toString() => value;
}


