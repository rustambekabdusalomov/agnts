//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/pull_item.dart';
import 'package:agnts_api/src/model/review_draft.dart';
import 'package:agnts_api/src/model/pull_review_ref.dart';
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:agnts_api/src/model/file_change.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pull_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullDetail {
  /// Returns a new [PullDetail] instance.
  PullDetail({

    required  this.repoId,

    required  this.repoName,

    required  this.provider,

    required  this.pull,

     this.body,

     this.login,

    required  this.files,

     this.filesError,

     this.ticketKey,

    required  this.own,

     this.ticketState,

     this.reviewedSha,

     this.afterApprove,

     this.reviews,

     this.drafts,
  });

  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;



  @JsonKey(
    
    name: r'repoName',
    required: true,
    includeIfNull: false,
  )


  final String repoName;



  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final PullDetailProviderEnum provider;



  @JsonKey(
    
    name: r'pull',
    required: true,
    includeIfNull: false,
  )


  final PullItem pull;



      /// The description, Markdown
  @JsonKey(
    
    name: r'body',
    required: false,
    includeIfNull: false,
  )


  final String? body;



      /// The git host token's user: who comments made here appear from
  @JsonKey(
    
    name: r'login',
    required: false,
    includeIfNull: false,
  )


  final String? login;



  @JsonKey(
    
    name: r'files',
    required: true,
    includeIfNull: false,
  )


  final List<FileChange> files;



      /// Why the files could not be read
  @JsonKey(
    
    name: r'filesError',
    required: false,
    includeIfNull: false,
  )


  final String? filesError;



  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;



  @JsonKey(
    
    name: r'own',
    required: true,
    includeIfNull: false,
  )


  final bool own;



  @JsonKey(
    
    name: r'ticketState',
    required: false,
    includeIfNull: false,
  )


  final TicketState? ticketState;



      /// The commit agnts reviewed, for a review ticket
  @JsonKey(
    
    name: r'reviewedSha',
    required: false,
    includeIfNull: false,
  )


  final String? reviewedSha;



  @JsonKey(
    
    name: r'afterApprove',
    required: false,
    includeIfNull: false,
  )


  final PullDetailAfterApproveEnum? afterApprove;



      /// agnts's reviews of it, newest first
  @JsonKey(
    
    name: r'reviews',
    required: false,
    includeIfNull: false,
  )


  final List<PullReviewRef>? reviews;



      /// The draft comments of agnts's newest review of it
  @JsonKey(
    
    name: r'drafts',
    required: false,
    includeIfNull: false,
  )


  final List<ReviewDraft>? drafts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullDetail &&
      other.repoId == repoId &&
      other.repoName == repoName &&
      other.provider == provider &&
      other.pull == pull &&
      other.body == body &&
      other.login == login &&
      other.files == files &&
      other.filesError == filesError &&
      other.ticketKey == ticketKey &&
      other.own == own &&
      other.ticketState == ticketState &&
      other.reviewedSha == reviewedSha &&
      other.afterApprove == afterApprove &&
      other.reviews == reviews &&
      other.drafts == drafts;

    @override
    int get hashCode =>
        repoId.hashCode +
        repoName.hashCode +
        provider.hashCode +
        pull.hashCode +
        body.hashCode +
        login.hashCode +
        files.hashCode +
        filesError.hashCode +
        ticketKey.hashCode +
        own.hashCode +
        ticketState.hashCode +
        reviewedSha.hashCode +
        afterApprove.hashCode +
        reviews.hashCode +
        drafts.hashCode;

  factory PullDetail.fromJson(Map<String, dynamic> json) => _$PullDetailFromJson(json);

  Map<String, dynamic> toJson() => _$PullDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PullDetailProviderEnum {
@JsonValue(r'github')
github(r'github'),
@JsonValue(r'gitlab')
gitlab(r'gitlab');

const PullDetailProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


enum PullDetailAfterApproveEnum {
@JsonValue(r'pr')
pr(r'pr'),
@JsonValue(r'main')
main(r'main'),
@JsonValue(r'none')
none(r'none');

const PullDetailAfterApproveEnum(this.value);

final String value;

@override
String toString() => value;
}


