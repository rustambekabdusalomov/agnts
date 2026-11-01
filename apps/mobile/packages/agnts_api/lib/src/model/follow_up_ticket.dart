//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_kind.dart';
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'follow_up_ticket.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FollowUpTicket {
  /// Returns a new [FollowUpTicket] instance.
  FollowUpTicket({

    required  this.key,

    required  this.title,

    required  this.state,

    required  this.kind,

    required  this.source_,

     this.held,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



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



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final TicketKind kind;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final FollowUpTicketSource_Enum source_;



  @JsonKey(
    
    name: r'held',
    required: false,
    includeIfNull: false,
  )


  final bool? held;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FollowUpTicket &&
      other.key == key &&
      other.title == title &&
      other.state == state &&
      other.kind == kind &&
      other.source_ == source_ &&
      other.held == held;

    @override
    int get hashCode =>
        key.hashCode +
        title.hashCode +
        state.hashCode +
        kind.hashCode +
        source_.hashCode +
        held.hashCode;

  factory FollowUpTicket.fromJson(Map<String, dynamic> json) => _$FollowUpTicketFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUpTicketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum FollowUpTicketSource_Enum {
@JsonValue(r'jira')
jira(r'jira'),
@JsonValue(r'plane')
plane(r'plane'),
@JsonValue(r'local')
local(r'local'),
@JsonValue(r'git')
git(r'git'),
@JsonValue(r'ci')
ci(r'ci'),
@JsonValue(r'logs')
logs(r'logs');

const FollowUpTicketSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


