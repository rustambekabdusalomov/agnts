//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/token_spend.dart';
import 'package:agnts_api/src/model/ticket_kind.dart';
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ticket_spend_row.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TicketSpendRow {
  /// Returns a new [TicketSpendRow] instance.
  TicketSpendRow({

    required  this.key,

    required  this.title,

    required  this.kind,

    required  this.state,

     this.repoName,

    required  this.calls,

    required  this.topStage,

    required  this.spend,
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
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final TicketKind kind;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final TicketState state;



  @JsonKey(
    
    name: r'repoName',
    required: false,
    includeIfNull: false,
  )


  final String? repoName;



      /// Claude invocations in the period
  @JsonKey(
    
    name: r'calls',
    required: true,
    includeIfNull: false,
  )


  final int calls;



      /// The stage that cost the most
  @JsonKey(
    
    name: r'topStage',
    required: true,
    includeIfNull: false,
  )


  final TicketSpendRowTopStageEnum topStage;



  @JsonKey(
    
    name: r'spend',
    required: true,
    includeIfNull: false,
  )


  final TokenSpend spend;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TicketSpendRow &&
      other.key == key &&
      other.title == title &&
      other.kind == kind &&
      other.state == state &&
      other.repoName == repoName &&
      other.calls == calls &&
      other.topStage == topStage &&
      other.spend == spend;

    @override
    int get hashCode =>
        key.hashCode +
        title.hashCode +
        kind.hashCode +
        state.hashCode +
        repoName.hashCode +
        calls.hashCode +
        topStage.hashCode +
        spend.hashCode;

  factory TicketSpendRow.fromJson(Map<String, dynamic> json) => _$TicketSpendRowFromJson(json);

  Map<String, dynamic> toJson() => _$TicketSpendRowToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// The stage that cost the most
enum TicketSpendRowTopStageEnum {
@JsonValue(r'analyze')
analyze(r'analyze'),
@JsonValue(r'coding')
coding(r'coding'),
@JsonValue(r'retry')
retry(r'retry'),
@JsonValue(r'helper')
helper(r'helper'),
@JsonValue(r'learn')
learn(r'learn'),
@JsonValue(r'review')
review(r'review'),
@JsonValue(r'preview')
preview(r'preview');

const TicketSpendRowTopStageEnum(this.value);

final String value;

@override
String toString() => value;
}


