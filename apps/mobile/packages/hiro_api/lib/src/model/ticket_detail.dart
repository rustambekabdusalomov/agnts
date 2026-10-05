//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/ticket.dart';
import 'package:hiro_api/src/model/question.dart';
import 'package:hiro_api/src/model/history_item.dart';
import 'package:hiro_api/src/model/stage_models.dart';
import 'package:hiro_api/src/model/analysis.dart';
import 'package:hiro_api/src/model/result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ticket_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TicketDetail {
  /// Returns a new [TicketDetail] instance.
  TicketDetail({

    required  this.ticket,

    required  this.questions,

     this.analysis,

     this.result,

     this.history,

     this.maxTurns,

     this.effectiveModels,
  });

  @JsonKey(
    
    name: r'ticket',
    required: true,
    includeIfNull: false,
  )


  final Ticket ticket;



  @JsonKey(
    
    name: r'questions',
    required: true,
    includeIfNull: false,
  )


  final List<Question> questions;



  @JsonKey(
    
    name: r'analysis',
    required: false,
    includeIfNull: false,
  )


  final Analysis? analysis;



  @JsonKey(
    
    name: r'result',
    required: false,
    includeIfNull: false,
  )


  final Result? result;



  @JsonKey(
    
    name: r'history',
    required: false,
    includeIfNull: false,
  )


  final List<HistoryItem>? history;



  @JsonKey(
    
    name: r'maxTurns',
    required: false,
    includeIfNull: false,
  )


  final int? maxTurns;



  @JsonKey(
    
    name: r'effectiveModels',
    required: false,
    includeIfNull: false,
  )


  final StageModels? effectiveModels;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TicketDetail &&
      other.ticket == ticket &&
      other.questions == questions &&
      other.analysis == analysis &&
      other.result == result &&
      other.history == history &&
      other.maxTurns == maxTurns &&
      other.effectiveModels == effectiveModels;

    @override
    int get hashCode =>
        ticket.hashCode +
        questions.hashCode +
        analysis.hashCode +
        result.hashCode +
        history.hashCode +
        maxTurns.hashCode +
        effectiveModels.hashCode;

  factory TicketDetail.fromJson(Map<String, dynamic> json) => _$TicketDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TicketDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

