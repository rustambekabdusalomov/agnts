//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commit_ticket.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommitTicket {
  /// Returns a new [CommitTicket] instance.
  CommitTicket({

    required  this.key,

     this.number,

    required  this.title,

    required  this.state,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



      /// The team's number, when the ticket has one
  @JsonKey(
    
    name: r'number',
    required: false,
    includeIfNull: false,
  )


  final String? number;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final TicketState state;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommitTicket &&
      other.key == key &&
      other.number == number &&
      other.title == title &&
      other.state == state;

    @override
    int get hashCode =>
        key.hashCode +
        number.hashCode +
        title.hashCode +
        state.hashCode;

  factory CommitTicket.fromJson(Map<String, dynamic> json) => _$CommitTicketFromJson(json);

  Map<String, dynamic> toJson() => _$CommitTicketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

