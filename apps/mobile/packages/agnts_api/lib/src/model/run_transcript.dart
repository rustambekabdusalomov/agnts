//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_transcript.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunTranscript {
  /// Returns a new [RunTranscript] instance.
  RunTranscript({

    required  this.id,

    required  this.workspaceId,

    required  this.workspace,

    required  this.workspaceSlug,

     this.runId,

     this.ticketKey,

     this.subject,

     this.claudeAccount,

     this.claudeUser,

    required  this.purpose,

    required  this.background,

     this.modelStage,

    required  this.engine,

    required  this.model,

     this.sessionId,

    required  this.startedAt,

     this.finishedAt,

    required  this.status,

    required  this.exitReason,

    required  this.turns,

    required  this.toolCalls,

    required  this.toolErrors,

    required  this.stalls,

    required  this.inputTokens,

    required  this.outputTokens,

    required  this.cacheReadTokens,

    required  this.cacheWriteTokens,

    required  this.costUsd,

    required  this.rawBytes,

    required  this.storedBytes,

    required  this.truncated,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'workspaceId',
    required: true,
    includeIfNull: false,
  )


  final int workspaceId;



  @JsonKey(
    
    name: r'workspace',
    required: true,
    includeIfNull: false,
  )


  final String workspace;



  @JsonKey(
    
    name: r'workspaceSlug',
    required: true,
    includeIfNull: false,
  )


  final String workspaceSlug;



  @JsonKey(
    
    name: r'runId',
    required: false,
    includeIfNull: false,
  )


  final int? runId;



  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;



      /// What a background call is about: a repository, a rule, a language
  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



      /// The Claude account's label
  @JsonKey(
    
    name: r'claudeAccount',
    required: false,
    includeIfNull: false,
  )


  final String? claudeAccount;



      /// The member whose Claude account it is (per-member mode)
  @JsonKey(
    
    name: r'claudeUser',
    required: false,
    includeIfNull: false,
  )


  final String? claudeUser;



  @JsonKey(
    
    name: r'purpose',
    required: true,
    includeIfNull: false,
  )


  final String purpose;



      /// A call outside a ticket's stages
  @JsonKey(
    
    name: r'background',
    required: true,
    includeIfNull: false,
  )


  final bool background;



  @JsonKey(
    
    name: r'modelStage',
    required: false,
    includeIfNull: false,
  )


  final String? modelStage;



  @JsonKey(
    
    name: r'engine',
    required: true,
    includeIfNull: false,
  )


  final RunTranscriptEngineEnum engine;



  @JsonKey(
    
    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final String model;



  @JsonKey(
    
    name: r'sessionId',
    required: false,
    includeIfNull: false,
  )


  final String? sessionId;



  @JsonKey(
    
    name: r'startedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime startedAt;



  @JsonKey(
    
    name: r'finishedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? finishedAt;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final RunTranscriptStatusEnum status;



  @JsonKey(
    
    name: r'exitReason',
    required: true,
    includeIfNull: false,
  )


  final String exitReason;



  @JsonKey(
    
    name: r'turns',
    required: true,
    includeIfNull: false,
  )


  final int turns;



  @JsonKey(
    
    name: r'toolCalls',
    required: true,
    includeIfNull: false,
  )


  final int toolCalls;



  @JsonKey(
    
    name: r'toolErrors',
    required: true,
    includeIfNull: false,
  )


  final int toolErrors;



  @JsonKey(
    
    name: r'stalls',
    required: true,
    includeIfNull: false,
  )


  final int stalls;



  @JsonKey(
    
    name: r'inputTokens',
    required: true,
    includeIfNull: false,
  )


  final int inputTokens;



  @JsonKey(
    
    name: r'outputTokens',
    required: true,
    includeIfNull: false,
  )


  final int outputTokens;



  @JsonKey(
    
    name: r'cacheReadTokens',
    required: true,
    includeIfNull: false,
  )


  final int cacheReadTokens;



  @JsonKey(
    
    name: r'cacheWriteTokens',
    required: true,
    includeIfNull: false,
  )


  final int cacheWriteTokens;



  @JsonKey(
    
    name: r'costUsd',
    required: true,
    includeIfNull: false,
  )


  final num costUsd;



      /// Uncompressed size of the events
  @JsonKey(
    
    name: r'rawBytes',
    required: true,
    includeIfNull: false,
  )


  final int rawBytes;



      /// Compressed size as stored
  @JsonKey(
    
    name: r'storedBytes',
    required: true,
    includeIfNull: false,
  )


  final int storedBytes;



      /// The size limit was reached; later content was left out
  @JsonKey(
    
    name: r'truncated',
    required: true,
    includeIfNull: false,
  )


  final bool truncated;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RunTranscript &&
      other.id == id &&
      other.workspaceId == workspaceId &&
      other.workspace == workspace &&
      other.workspaceSlug == workspaceSlug &&
      other.runId == runId &&
      other.ticketKey == ticketKey &&
      other.subject == subject &&
      other.claudeAccount == claudeAccount &&
      other.claudeUser == claudeUser &&
      other.purpose == purpose &&
      other.background == background &&
      other.modelStage == modelStage &&
      other.engine == engine &&
      other.model == model &&
      other.sessionId == sessionId &&
      other.startedAt == startedAt &&
      other.finishedAt == finishedAt &&
      other.status == status &&
      other.exitReason == exitReason &&
      other.turns == turns &&
      other.toolCalls == toolCalls &&
      other.toolErrors == toolErrors &&
      other.stalls == stalls &&
      other.inputTokens == inputTokens &&
      other.outputTokens == outputTokens &&
      other.cacheReadTokens == cacheReadTokens &&
      other.cacheWriteTokens == cacheWriteTokens &&
      other.costUsd == costUsd &&
      other.rawBytes == rawBytes &&
      other.storedBytes == storedBytes &&
      other.truncated == truncated;

    @override
    int get hashCode =>
        id.hashCode +
        workspaceId.hashCode +
        workspace.hashCode +
        workspaceSlug.hashCode +
        runId.hashCode +
        ticketKey.hashCode +
        subject.hashCode +
        claudeAccount.hashCode +
        claudeUser.hashCode +
        purpose.hashCode +
        background.hashCode +
        modelStage.hashCode +
        engine.hashCode +
        model.hashCode +
        sessionId.hashCode +
        startedAt.hashCode +
        finishedAt.hashCode +
        status.hashCode +
        exitReason.hashCode +
        turns.hashCode +
        toolCalls.hashCode +
        toolErrors.hashCode +
        stalls.hashCode +
        inputTokens.hashCode +
        outputTokens.hashCode +
        cacheReadTokens.hashCode +
        cacheWriteTokens.hashCode +
        costUsd.hashCode +
        rawBytes.hashCode +
        storedBytes.hashCode +
        truncated.hashCode;

  factory RunTranscript.fromJson(Map<String, dynamic> json) => _$RunTranscriptFromJson(json);

  Map<String, dynamic> toJson() => _$RunTranscriptToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum RunTranscriptEngineEnum {
@JsonValue(r'claude')
claude(r'claude'),
@JsonValue(r'codex')
codex(r'codex');

const RunTranscriptEngineEnum(this.value);

final String value;

@override
String toString() => value;
}


enum RunTranscriptStatusEnum {
@JsonValue(r'running')
running(r'running'),
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'error')
error(r'error'),
@JsonValue(r'timeout')
timeout(r'timeout'),
@JsonValue(r'cancelled')
cancelled(r'cancelled'),
@JsonValue(r'oom')
oom(r'oom');

const RunTranscriptStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


