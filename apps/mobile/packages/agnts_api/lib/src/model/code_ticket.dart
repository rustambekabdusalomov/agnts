//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_kind.dart';
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'code_ticket.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CodeTicket {
  /// Returns a new [CodeTicket] instance.
  CodeTicket({

    required  this.key,

    required  this.title,

    required  this.state,

    required  this.kind,

    required  this.repos,

    required  this.current,

    required  this.moved,

    required  this.attachedAt,
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



      /// Repository names, the primary first
  @JsonKey(
    
    name: r'repos',
    required: true,
    includeIfNull: false,
  )


  final List<String> repos;



      /// New messages go to it
  @JsonKey(
    
    name: r'current',
    required: true,
    includeIfNull: false,
  )


  final bool current;



      /// Another of your conversations has it now
  @JsonKey(
    
    name: r'moved',
    required: true,
    includeIfNull: false,
  )


  final bool moved;



  @JsonKey(
    
    name: r'attachedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime attachedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CodeTicket &&
      other.key == key &&
      other.title == title &&
      other.state == state &&
      other.kind == kind &&
      other.repos == repos &&
      other.current == current &&
      other.moved == moved &&
      other.attachedAt == attachedAt;

    @override
    int get hashCode =>
        key.hashCode +
        title.hashCode +
        state.hashCode +
        kind.hashCode +
        repos.hashCode +
        current.hashCode +
        moved.hashCode +
        attachedAt.hashCode;

  factory CodeTicket.fromJson(Map<String, dynamic> json) => _$CodeTicketFromJson(json);

  Map<String, dynamic> toJson() => _$CodeTicketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

