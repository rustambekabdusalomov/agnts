//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document_source_input_filter.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_source_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentSourceInput {
  /// Returns a new [DocumentSourceInput] instance.
  DocumentSourceInput({

    required  this.kind,

     this.template,

     this.documentId,

     this.documentVersion,

     this.instruction,

     this.tickets,

     this.filter,

     this.repoIds,

     this.branch,

     this.author,

     this.prState,

     this.prNumbers,

     this.from,

     this.to,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final DocumentSourceInputKindEnum kind;



      /// Defaults by kind
  @JsonKey(
    
    name: r'template',
    required: false,
    includeIfNull: false,
  )


  final DocumentSourceInputTemplateEnum? template;



  @JsonKey(
    
    name: r'documentId',
    required: false,
    includeIfNull: false,
  )


  final int? documentId;



          // minimum: 0
  @JsonKey(
    
    name: r'documentVersion',
    required: false,
    includeIfNull: false,
  )


  final int? documentVersion;



  @JsonKey(
    
    name: r'instruction',
    required: false,
    includeIfNull: false,
  )


  final String? instruction;



  @JsonKey(
    
    name: r'tickets',
    required: false,
    includeIfNull: false,
  )


  final List<String>? tickets;



  @JsonKey(
    
    name: r'filter',
    required: false,
    includeIfNull: false,
  )


  final DocumentSourceInputFilter? filter;



  @JsonKey(
    
    name: r'repoIds',
    required: false,
    includeIfNull: false,
  )


  final List<int>? repoIds;



  @JsonKey(
    
    name: r'branch',
    required: false,
    includeIfNull: false,
  )


  final String? branch;



  @JsonKey(
    
    name: r'author',
    required: false,
    includeIfNull: false,
  )


  final String? author;



  @JsonKey(
    
    name: r'prState',
    required: false,
    includeIfNull: false,
  )


  final DocumentSourceInputPrStateEnum? prState;



  @JsonKey(
    
    name: r'prNumbers',
    required: false,
    includeIfNull: false,
  )


  final List<int>? prNumbers;



  @JsonKey(
    
    name: r'from',
    required: false,
    includeIfNull: false,
  )


  final DateTime? from;



  @JsonKey(
    
    name: r'to',
    required: false,
    includeIfNull: false,
  )


  final DateTime? to;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentSourceInput &&
      other.kind == kind &&
      other.template == template &&
      other.documentId == documentId &&
      other.documentVersion == documentVersion &&
      other.instruction == instruction &&
      other.tickets == tickets &&
      other.filter == filter &&
      other.repoIds == repoIds &&
      other.branch == branch &&
      other.author == author &&
      other.prState == prState &&
      other.prNumbers == prNumbers &&
      other.from == from &&
      other.to == to;

    @override
    int get hashCode =>
        kind.hashCode +
        template.hashCode +
        documentId.hashCode +
        documentVersion.hashCode +
        instruction.hashCode +
        tickets.hashCode +
        filter.hashCode +
        repoIds.hashCode +
        branch.hashCode +
        author.hashCode +
        prState.hashCode +
        prNumbers.hashCode +
        from.hashCode +
        to.hashCode;

  factory DocumentSourceInput.fromJson(Map<String, dynamic> json) => _$DocumentSourceInputFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentSourceInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentSourceInputKindEnum {
@JsonValue(r'report')
report(r'report'),
@JsonValue(r'tickets')
tickets(r'tickets'),
@JsonValue(r'commits')
commits(r'commits'),
@JsonValue(r'pulls')
pulls(r'pulls'),
@JsonValue(r'repo')
repo(r'repo'),
@JsonValue(r'document')
document(r'document');

const DocumentSourceInputKindEnum(this.value);

final String value;

@override
String toString() => value;
}


/// Defaults by kind
enum DocumentSourceInputTemplateEnum {
@JsonValue(r'status')
status(r'status'),
@JsonValue(r'release_notes')
releaseNotes(r'release_notes'),
@JsonValue(r'pr_review')
prReview(r'pr_review'),
@JsonValue(r'repo_review')
repoReview(r'repo_review'),
@JsonValue(r'ticket_summary')
ticketSummary(r'ticket_summary'),
@JsonValue(r'presentation')
presentation(r'presentation'),
@JsonValue(r'blank')
blank(r'blank');

const DocumentSourceInputTemplateEnum(this.value);

final String value;

@override
String toString() => value;
}


enum DocumentSourceInputPrStateEnum {
@JsonValue(r'open')
open(r'open'),
@JsonValue(r'merged')
merged(r'merged'),
@JsonValue(r'all')
all(r'all');

const DocumentSourceInputPrStateEnum(this.value);

final String value;

@override
String toString() => value;
}


