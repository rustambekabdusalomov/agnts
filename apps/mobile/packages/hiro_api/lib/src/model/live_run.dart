//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/ticket.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'live_run.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LiveRun {
  /// Returns a new [LiveRun] instance.
  LiveRun({

    required  this.ticket,

    required  this.model,

    required  this.turns,

    required  this.maxTurns,

    required  this.lastMessage,
  });

  @JsonKey(
    
    name: r'ticket',
    required: true,
    includeIfNull: false,
  )


  final Ticket ticket;



  @JsonKey(
    
    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final String model;



  @JsonKey(
    
    name: r'turns',
    required: true,
    includeIfNull: false,
  )


  final int turns;



  @JsonKey(
    
    name: r'maxTurns',
    required: true,
    includeIfNull: false,
  )


  final int maxTurns;



  @JsonKey(
    
    name: r'lastMessage',
    required: true,
    includeIfNull: false,
  )


  final String lastMessage;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LiveRun &&
      other.ticket == ticket &&
      other.model == model &&
      other.turns == turns &&
      other.maxTurns == maxTurns &&
      other.lastMessage == lastMessage;

    @override
    int get hashCode =>
        ticket.hashCode +
        model.hashCode +
        turns.hashCode +
        maxTurns.hashCode +
        lastMessage.hashCode;

  factory LiveRun.fromJson(Map<String, dynamic> json) => _$LiveRunFromJson(json);

  Map<String, dynamic> toJson() => _$LiveRunToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

