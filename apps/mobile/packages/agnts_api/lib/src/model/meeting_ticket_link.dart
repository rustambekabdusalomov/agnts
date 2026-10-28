//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_ticket_link.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingTicketLink {
  /// Returns a new [MeetingTicketLink] instance.
  MeetingTicketLink({

    required  this.meetingId,

    required  this.meetingTitle,

    required  this.meetingCode,

     this.sessionId,

    required  this.ticketKey,

    required  this.quote,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'meetingId',
    required: true,
    includeIfNull: false,
  )


  final int meetingId;



  @JsonKey(
    
    name: r'meetingTitle',
    required: true,
    includeIfNull: false,
  )


  final String meetingTitle;



  @JsonKey(
    
    name: r'meetingCode',
    required: true,
    includeIfNull: false,
  )


  final String meetingCode;



  @JsonKey(
    
    name: r'sessionId',
    required: false,
    includeIfNull: false,
  )


  final int? sessionId;



  @JsonKey(
    
    name: r'ticketKey',
    required: true,
    includeIfNull: false,
  )


  final String ticketKey;



  @JsonKey(
    
    name: r'quote',
    required: true,
    includeIfNull: false,
  )


  final String quote;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingTicketLink &&
      other.meetingId == meetingId &&
      other.meetingTitle == meetingTitle &&
      other.meetingCode == meetingCode &&
      other.sessionId == sessionId &&
      other.ticketKey == ticketKey &&
      other.quote == quote &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        meetingId.hashCode +
        meetingTitle.hashCode +
        meetingCode.hashCode +
        sessionId.hashCode +
        ticketKey.hashCode +
        quote.hashCode +
        createdAt.hashCode;

  factory MeetingTicketLink.fromJson(Map<String, dynamic> json) => _$MeetingTicketLinkFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingTicketLinkToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

