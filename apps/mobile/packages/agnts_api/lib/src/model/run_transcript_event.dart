//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_transcript_event.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunTranscriptEvent {
  /// Returns a new [RunTranscriptEvent] instance.
  RunTranscriptEvent({

    required  this.k,

    required  this.t,

     this.text,

     this.id,

     this.name,

     this.summary,

     this.input,

     this.output,

     this.error,

     this.exitCode,

     this.cut,

     this.subtype,

     this.turns,

     this.cost,

     this.status,

     this.sessionId,

     this.model,
  });

      /// init, text, tool, tool_result, rate_limit, result or note; clients show kinds they do not know as is
  @JsonKey(
    
    name: r'k',
    required: true,
    includeIfNull: false,
  )


  final String k;



  @JsonKey(
    
    name: r't',
    required: true,
    includeIfNull: false,
  )


  final int t;



      /// text, result, note: the text
  @JsonKey(
    
    name: r'text',
    required: false,
    includeIfNull: false,
  )


  final String? text;



      /// tool, tool_result: pairs a result with its call
  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



      /// tool: the tool (Bash, Read, Edit…)
  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



      /// tool: a one-line summary of the call
  @JsonKey(
    
    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final String? summary;



      /// tool: the input as given (an object), or as text when it was too big to keep as JSON (cut is then set)
  @JsonKey(
    
    name: r'input',
    required: false,
    includeIfNull: false,
  )


  final Object? input;



      /// tool_result: what the tool returned
  @JsonKey(
    
    name: r'output',
    required: false,
    includeIfNull: false,
  )


  final String? output;



      /// tool_result, result: it failed
  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final bool? error;



      /// tool_result: a command's exit code (Codex)
  @JsonKey(
    
    name: r'exit_code',
    required: false,
    includeIfNull: false,
  )


  final int? exitCode;



      /// The original length in bytes when the content was shortened
  @JsonKey(
    
    name: r'cut',
    required: false,
    includeIfNull: false,
  )


  final int? cut;



      /// result: success, error_max_turns…
  @JsonKey(
    
    name: r'subtype',
    required: false,
    includeIfNull: false,
  )


  final String? subtype;



      /// result: turns taken
  @JsonKey(
    
    name: r'turns',
    required: false,
    includeIfNull: false,
  )


  final int? turns;



      /// result: cost in USD
  @JsonKey(
    
    name: r'cost',
    required: false,
    includeIfNull: false,
  )


  final num? cost;



      /// rate_limit: the plan usage status
  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



      /// init: the Claude Code session
  @JsonKey(
    
    name: r'session_id',
    required: false,
    includeIfNull: false,
  )


  final String? sessionId;



      /// init: the model Claude Code reported
  @JsonKey(
    
    name: r'model',
    required: false,
    includeIfNull: false,
  )


  final String? model;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RunTranscriptEvent &&
      other.k == k &&
      other.t == t &&
      other.text == text &&
      other.id == id &&
      other.name == name &&
      other.summary == summary &&
      other.input == input &&
      other.output == output &&
      other.error == error &&
      other.exitCode == exitCode &&
      other.cut == cut &&
      other.subtype == subtype &&
      other.turns == turns &&
      other.cost == cost &&
      other.status == status &&
      other.sessionId == sessionId &&
      other.model == model;

    @override
    int get hashCode =>
        k.hashCode +
        t.hashCode +
        text.hashCode +
        id.hashCode +
        name.hashCode +
        summary.hashCode +
        (input == null ? 0 : input.hashCode) +
        output.hashCode +
        error.hashCode +
        exitCode.hashCode +
        cut.hashCode +
        subtype.hashCode +
        turns.hashCode +
        cost.hashCode +
        status.hashCode +
        sessionId.hashCode +
        model.hashCode;

  factory RunTranscriptEvent.fromJson(Map<String, dynamic> json) => _$RunTranscriptEventFromJson(json);

  Map<String, dynamic> toJson() => _$RunTranscriptEventToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

