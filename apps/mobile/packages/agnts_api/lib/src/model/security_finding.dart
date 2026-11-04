//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/sec_finding_status.dart';
import 'package:agnts_api/src/model/sec_severity.dart';
import 'package:agnts_api/src/model/security_finding_location.dart';
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'security_finding.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecurityFinding {
  /// Returns a new [SecurityFinding] instance.
  SecurityFinding({

    required  this.id,

    required  this.repoId,

    required  this.repo,

    required  this.severity,

    required  this.category,

    required  this.source_,

     this.symbol,

    required  this.status,

    required  this.title,

     this.cwe,

     this.owasp,

    required  this.location,

     this.tool,

    required  this.rules,

    required  this.confidence,

     this.evidence,

     this.impact,

     this.fixExplanation,

     this.fixPatch,

    required  this.references,

     this.package,

     this.version,

     this.ecosystem,

     this.fixedIn,

     this.advisories,

     this.cvss,

     this.secretMask,

     this.commit,

     this.note,

    required  this.ticketKey,

     this.ticketState,

    required  this.dismissReason,

    required  this.dismissNote,

    required  this.firstSeen,

    required  this.lastSeen,

    required  this.lastChecked,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;



  @JsonKey(
    
    name: r'repo',
    required: true,
    includeIfNull: false,
  )


  final String repo;



  @JsonKey(
    
    name: r'severity',
    required: true,
    includeIfNull: false,
  )


  final SecSeverity severity;



  @JsonKey(
    
    name: r'category',
    required: true,
    includeIfNull: false,
  )


  final String category;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final SecurityFindingSource_Enum source_;



      /// The enclosing function
  @JsonKey(
    
    name: r'symbol',
    required: false,
    includeIfNull: false,
  )


  final String? symbol;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final SecFindingStatus status;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'cwe',
    required: false,
    includeIfNull: false,
  )


  final String? cwe;



  @JsonKey(
    
    name: r'owasp',
    required: false,
    includeIfNull: false,
  )


  final String? owasp;



  @JsonKey(
    
    name: r'location',
    required: true,
    includeIfNull: false,
  )


  final SecurityFindingLocation location;



  @JsonKey(
    
    name: r'tool',
    required: false,
    includeIfNull: false,
  )


  final String? tool;



  @JsonKey(
    
    name: r'rules',
    required: true,
    includeIfNull: false,
  )


  final List<String> rules;



  @JsonKey(
    
    name: r'confidence',
    required: true,
    includeIfNull: false,
  )


  final SecurityFindingConfidenceEnum confidence;



  @JsonKey(
    
    name: r'evidence',
    required: false,
    includeIfNull: false,
  )


  final String? evidence;



  @JsonKey(
    
    name: r'impact',
    required: false,
    includeIfNull: false,
  )


  final String? impact;



  @JsonKey(
    
    name: r'fixExplanation',
    required: false,
    includeIfNull: false,
  )


  final String? fixExplanation;



  @JsonKey(
    
    name: r'fixPatch',
    required: false,
    includeIfNull: false,
  )


  final String? fixPatch;



  @JsonKey(
    
    name: r'references',
    required: true,
    includeIfNull: false,
  )


  final List<String> references;



  @JsonKey(
    
    name: r'package',
    required: false,
    includeIfNull: false,
  )


  final String? package;



  @JsonKey(
    
    name: r'version',
    required: false,
    includeIfNull: false,
  )


  final String? version;



  @JsonKey(
    
    name: r'ecosystem',
    required: false,
    includeIfNull: false,
  )


  final String? ecosystem;



  @JsonKey(
    
    name: r'fixedIn',
    required: false,
    includeIfNull: false,
  )


  final String? fixedIn;



  @JsonKey(
    
    name: r'advisories',
    required: false,
    includeIfNull: false,
  )


  final List<String>? advisories;



  @JsonKey(
    
    name: r'cvss',
    required: false,
    includeIfNull: false,
  )


  final String? cvss;



      /// The secret's first characters; agnts never stores the value
  @JsonKey(
    
    name: r'secretMask',
    required: false,
    includeIfNull: false,
  )


  final String? secretMask;



  @JsonKey(
    
    name: r'commit',
    required: false,
    includeIfNull: false,
  )


  final String? commit;



      /// What the last recheck said
  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;



  @JsonKey(
    
    name: r'ticketKey',
    required: true,
    includeIfNull: false,
  )


  final String ticketKey;



  @JsonKey(
    
    name: r'ticketState',
    required: false,
    includeIfNull: false,
  )


  final TicketState? ticketState;



  @JsonKey(
    
    name: r'dismissReason',
    required: true,
    includeIfNull: false,
  )


  final String dismissReason;



  @JsonKey(
    
    name: r'dismissNote',
    required: true,
    includeIfNull: false,
  )


  final String dismissNote;



  @JsonKey(
    
    name: r'firstSeen',
    required: true,
    includeIfNull: false,
  )


  final DateTime firstSeen;



  @JsonKey(
    
    name: r'lastSeen',
    required: true,
    includeIfNull: false,
  )


  final DateTime lastSeen;



  @JsonKey(
    
    name: r'lastChecked',
    required: true,
    includeIfNull: false,
  )


  final DateTime lastChecked;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecurityFinding &&
      other.id == id &&
      other.repoId == repoId &&
      other.repo == repo &&
      other.severity == severity &&
      other.category == category &&
      other.source_ == source_ &&
      other.symbol == symbol &&
      other.status == status &&
      other.title == title &&
      other.cwe == cwe &&
      other.owasp == owasp &&
      other.location == location &&
      other.tool == tool &&
      other.rules == rules &&
      other.confidence == confidence &&
      other.evidence == evidence &&
      other.impact == impact &&
      other.fixExplanation == fixExplanation &&
      other.fixPatch == fixPatch &&
      other.references == references &&
      other.package == package &&
      other.version == version &&
      other.ecosystem == ecosystem &&
      other.fixedIn == fixedIn &&
      other.advisories == advisories &&
      other.cvss == cvss &&
      other.secretMask == secretMask &&
      other.commit == commit &&
      other.note == note &&
      other.ticketKey == ticketKey &&
      other.ticketState == ticketState &&
      other.dismissReason == dismissReason &&
      other.dismissNote == dismissNote &&
      other.firstSeen == firstSeen &&
      other.lastSeen == lastSeen &&
      other.lastChecked == lastChecked;

    @override
    int get hashCode =>
        id.hashCode +
        repoId.hashCode +
        repo.hashCode +
        severity.hashCode +
        category.hashCode +
        source_.hashCode +
        symbol.hashCode +
        status.hashCode +
        title.hashCode +
        cwe.hashCode +
        owasp.hashCode +
        location.hashCode +
        tool.hashCode +
        rules.hashCode +
        confidence.hashCode +
        evidence.hashCode +
        impact.hashCode +
        fixExplanation.hashCode +
        fixPatch.hashCode +
        references.hashCode +
        package.hashCode +
        version.hashCode +
        ecosystem.hashCode +
        fixedIn.hashCode +
        advisories.hashCode +
        cvss.hashCode +
        secretMask.hashCode +
        commit.hashCode +
        note.hashCode +
        ticketKey.hashCode +
        ticketState.hashCode +
        dismissReason.hashCode +
        dismissNote.hashCode +
        firstSeen.hashCode +
        lastSeen.hashCode +
        lastChecked.hashCode;

  factory SecurityFinding.fromJson(Map<String, dynamic> json) => _$SecurityFindingFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityFindingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum SecurityFindingSource_Enum {
@JsonValue(r'code')
code(r'code'),
@JsonValue(r'config')
config(r'config'),
@JsonValue(r'dependency')
dependency(r'dependency'),
@JsonValue(r'secret')
secret(r'secret'),
@JsonValue(r'history')
history(r'history'),
@JsonValue(r'agent')
agent(r'agent'),
@JsonValue(r'logs')
logs(r'logs');

const SecurityFindingSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


enum SecurityFindingConfidenceEnum {
@JsonValue(r'confirmed')
confirmed(r'confirmed'),
@JsonValue(r'likely')
likely(r'likely'),
@JsonValue(r'possible')
possible(r'possible');

const SecurityFindingConfidenceEnum(this.value);

final String value;

@override
String toString() => value;
}


