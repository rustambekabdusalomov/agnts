//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'related_ticket.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RelatedTicket {
  /// Returns a new [RelatedTicket] instance.
  RelatedTicket({

    required  this.key,

    required  this.title,

    required  this.state,

    required  this.landed,
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



      /// Its change is merged (or it was rejected): it holds nothing back
  @JsonKey(
    
    name: r'landed',
    required: true,
    includeIfNull: false,
  )


  final bool landed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RelatedTicket &&
      other.key == key &&
      other.title == title &&
      other.state == state &&
      other.landed == landed;

    @override
    int get hashCode =>
        key.hashCode +
        title.hashCode +
        state.hashCode +
        landed.hashCode;

  factory RelatedTicket.fromJson(Map<String, dynamic> json) => _$RelatedTicketFromJson(json);

  Map<String, dynamic> toJson() => _$RelatedTicketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

