//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/rule_question.dart';
import 'package:agnts_api/src/model/rule_status.dart';
import 'package:agnts_api/src/model/rule_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Rule {
  /// Returns a new [Rule] instance.
  Rule({

    required  this.id,

    required  this.kind,

     this.sourceTicket,

     this.reason,

     this.repoId,

     this.repoName,

    required  this.title,

    required  this.body,

    required  this.enabled,

    required  this.status,

    required  this.interpretation,

    required  this.clarified,

    required  this.text,

    required  this.questions,

    required  this.rounds,

    required  this.error,

     this.analyzedAt,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final RuleKind kind;



      /// For a rule agnts suggested: the ticket whose feedback taught it
  @JsonKey(
    
    name: r'sourceTicket',
    required: false,
    includeIfNull: false,
  )


  final String? sourceTicket;



      /// For a rule agnts suggested: which feedback shows it
  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;



      /// Absent for a global rule
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



  @JsonKey(
    
    name: r'repoName',
    required: false,
    includeIfNull: false,
  )


  final String? repoName;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



      /// The rule as written
  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final RuleStatus status;



      /// What Claude will do because of the rule
  @JsonKey(
    
    name: r'interpretation',
    required: true,
    includeIfNull: false,
  )


  final String interpretation;



      /// The rule rewritten with what the answers settled; empty when used as written
  @JsonKey(
    
    name: r'clarified',
    required: true,
    includeIfNull: false,
  )


  final String clarified;



      /// What tickets are given
  @JsonKey(
    
    name: r'text',
    required: true,
    includeIfNull: false,
  )


  final String text;



  @JsonKey(
    
    name: r'questions',
    required: true,
    includeIfNull: false,
  )


  final List<RuleQuestion> questions;



      /// Question rounds so far
  @JsonKey(
    
    name: r'rounds',
    required: true,
    includeIfNull: false,
  )


  final int rounds;



      /// Why the last review failed
  @JsonKey(
    
    name: r'error',
    required: true,
    includeIfNull: false,
  )


  final String error;



  @JsonKey(
    
    name: r'analyzedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? analyzedAt;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Rule &&
      other.id == id &&
      other.kind == kind &&
      other.sourceTicket == sourceTicket &&
      other.reason == reason &&
      other.repoId == repoId &&
      other.repoName == repoName &&
      other.title == title &&
      other.body == body &&
      other.enabled == enabled &&
      other.status == status &&
      other.interpretation == interpretation &&
      other.clarified == clarified &&
      other.text == text &&
      other.questions == questions &&
      other.rounds == rounds &&
      other.error == error &&
      other.analyzedAt == analyzedAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        sourceTicket.hashCode +
        reason.hashCode +
        repoId.hashCode +
        repoName.hashCode +
        title.hashCode +
        body.hashCode +
        enabled.hashCode +
        status.hashCode +
        interpretation.hashCode +
        clarified.hashCode +
        text.hashCode +
        questions.hashCode +
        rounds.hashCode +
        error.hashCode +
        analyzedAt.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);

  Map<String, dynamic> toJson() => _$RuleToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

