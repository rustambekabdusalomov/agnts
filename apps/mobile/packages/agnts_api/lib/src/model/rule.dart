//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/rule_enforce.dart';
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

     this.tag,

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

     this.enforce,

     this.delivery,

     this.skillDescription,

     this.source_,

     this.confidence,

     this.evidence,

     this.lastSeen,

     this.watching,

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



      /// For a rule agnts learned: what kind of lesson it is
  @JsonKey(
    
    name: r'tag',
    required: false,
    includeIfNull: false,
  )


  final RuleTagEnum? tag;



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
    
    name: r'enforce',
    required: false,
    includeIfNull: false,
  )


  final RuleEnforce? enforce;



      /// prompt: in every prompt; skill: a skill Claude loads when its description matches the work
  @JsonKey(
    
    name: r'delivery',
    required: false,
    includeIfNull: false,
  )


  final RuleDeliveryEnum? delivery;



      /// When the rule applies, for its skill
  @JsonKey(
    
    name: r'skillDescription',
    required: false,
    includeIfNull: false,
  )


  final String? skillDescription;



      /// Where it came from: empty (a person), reflect, run, promoted or pack:<language>
  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final String? source_;



      /// For a learned suggestion: 0.3 to 0.9, earned each time it is seen again
  @JsonKey(
    
    name: r'confidence',
    required: false,
    includeIfNull: false,
  )


  final num? confidence;



      /// How many times a learned suggestion was seen
  @JsonKey(
    
    name: r'evidence',
    required: false,
    includeIfNull: false,
  )


  final int? evidence;



  @JsonKey(
    
    name: r'lastSeen',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastSeen;



      /// A learned suggestion with too little evidence to show yet
  @JsonKey(
    
    name: r'watching',
    required: false,
    includeIfNull: false,
  )


  final bool? watching;



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
      other.tag == tag &&
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
      other.enforce == enforce &&
      other.delivery == delivery &&
      other.skillDescription == skillDescription &&
      other.source_ == source_ &&
      other.confidence == confidence &&
      other.evidence == evidence &&
      other.lastSeen == lastSeen &&
      other.watching == watching &&
      other.analyzedAt == analyzedAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        sourceTicket.hashCode +
        tag.hashCode +
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
        enforce.hashCode +
        delivery.hashCode +
        skillDescription.hashCode +
        source_.hashCode +
        confidence.hashCode +
        evidence.hashCode +
        lastSeen.hashCode +
        watching.hashCode +
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

/// For a rule agnts learned: what kind of lesson it is
enum RuleTagEnum {
@JsonValue(r'reuse')
reuse(r'reuse'),
@JsonValue(r'layer')
layer(r'layer'),
@JsonValue(r'tests')
tests(r'tests'),
@JsonValue(r'style')
style(r'style'),
@JsonValue(r'logic')
logic(r'logic'),
@JsonValue(r'other')
other(r'other');

const RuleTagEnum(this.value);

final String value;

@override
String toString() => value;
}


/// prompt: in every prompt; skill: a skill Claude loads when its description matches the work
enum RuleDeliveryEnum {
@JsonValue(r'prompt')
prompt(r'prompt'),
@JsonValue(r'skill')
skill(r'skill');

const RuleDeliveryEnum(this.value);

final String value;

@override
String toString() => value;
}


