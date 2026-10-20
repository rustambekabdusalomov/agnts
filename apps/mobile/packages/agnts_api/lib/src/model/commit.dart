//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/commit_ticket.dart';
import 'package:agnts_api/src/model/ci.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commit.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Commit {
  /// Returns a new [Commit] instance.
  Commit({

    required  this.sha,

    required  this.message,

    required  this.author,

     this.date,

    required  this.add,

    required  this.del,

    required  this.ci,

     this.url,

     this.ticketKey,

     this.tickets,
  });

  @JsonKey(
    
    name: r'sha',
    required: true,
    includeIfNull: false,
  )


  final String sha;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'author',
    required: true,
    includeIfNull: false,
  )


  final String author;



  @JsonKey(
    
    name: r'date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? date;



  @JsonKey(
    
    name: r'add',
    required: true,
    includeIfNull: false,
  )


  final int add;



  @JsonKey(
    
    name: r'del',
    required: true,
    includeIfNull: false,
  )


  final int del;



  @JsonKey(
    
    name: r'ci',
    required: true,
    includeIfNull: false,
  )


  final CI ci;



  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



      /// The first linked ticket's key, else the KEY-1 before the message's colon
  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;



      /// The tickets the commit is linked to
  @JsonKey(
    
    name: r'tickets',
    required: false,
    includeIfNull: false,
  )


  final List<CommitTicket>? tickets;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Commit &&
      other.sha == sha &&
      other.message == message &&
      other.author == author &&
      other.date == date &&
      other.add == add &&
      other.del == del &&
      other.ci == ci &&
      other.url == url &&
      other.ticketKey == ticketKey &&
      other.tickets == tickets;

    @override
    int get hashCode =>
        sha.hashCode +
        message.hashCode +
        author.hashCode +
        date.hashCode +
        add.hashCode +
        del.hashCode +
        ci.hashCode +
        url.hashCode +
        ticketKey.hashCode +
        tickets.hashCode;

  factory Commit.fromJson(Map<String, dynamic> json) => _$CommitFromJson(json);

  Map<String, dynamic> toJson() => _$CommitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

