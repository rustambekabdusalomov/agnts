//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_ticket.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentTicket {
  /// Returns a new [DocumentTicket] instance.
  DocumentTicket({

    required  this.key,

    required  this.number,

    required  this.title,

    required  this.state,

    required  this.kind,

     this.linkedBy,

    required  this.linkedAt,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'number',
    required: true,
    includeIfNull: false,
  )


  final String number;



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


  final String state;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final String kind;



      /// Absent when agnts linked it
  @JsonKey(
    
    name: r'linkedBy',
    required: false,
    includeIfNull: false,
  )


  final int? linkedBy;



  @JsonKey(
    
    name: r'linkedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime linkedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentTicket &&
      other.key == key &&
      other.number == number &&
      other.title == title &&
      other.state == state &&
      other.kind == kind &&
      other.linkedBy == linkedBy &&
      other.linkedAt == linkedAt;

    @override
    int get hashCode =>
        key.hashCode +
        number.hashCode +
        title.hashCode +
        state.hashCode +
        kind.hashCode +
        linkedBy.hashCode +
        linkedAt.hashCode;

  factory DocumentTicket.fromJson(Map<String, dynamic> json) => _$DocumentTicketFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentTicketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

