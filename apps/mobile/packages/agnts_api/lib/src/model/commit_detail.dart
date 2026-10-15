//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/pipeline.dart';
import 'package:agnts_api/src/model/commit_pull.dart';
import 'package:agnts_api/src/model/file_change.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commit_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommitDetail {
  /// Returns a new [CommitDetail] instance.
  CommitDetail({

    required  this.sha,

    required  this.message,

    required  this.author,

     this.authorEmail,

     this.authorLogin,

     this.authorAvatar,

     this.date,

     this.committer,

     this.committerEmail,

     this.committedDate,

    required  this.parents,

    required  this.url,

    required  this.add,

    required  this.del,

    required  this.files,

     this.filesCapped,

    required  this.pipelines,

    required  this.pulls,

     this.ticketKey,

    required  this.provider,
  });

  @JsonKey(
    
    name: r'sha',
    required: true,
    includeIfNull: false,
  )


  final String sha;



      /// The full commit message
  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'author',
    required: true,
    includeIfNull: false,
  )


  final String author;



  @JsonKey(
    
    name: r'authorEmail',
    required: false,
    includeIfNull: false,
  )


  final String? authorEmail;



      /// The git host account, when the author's email maps to one
  @JsonKey(
    
    name: r'authorLogin',
    required: false,
    includeIfNull: false,
  )


  final String? authorLogin;



  @JsonKey(
    
    name: r'authorAvatar',
    required: false,
    includeIfNull: false,
  )


  final String? authorAvatar;



      /// Authored
  @JsonKey(
    
    name: r'date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? date;



  @JsonKey(
    
    name: r'committer',
    required: false,
    includeIfNull: false,
  )


  final String? committer;



  @JsonKey(
    
    name: r'committerEmail',
    required: false,
    includeIfNull: false,
  )


  final String? committerEmail;



  @JsonKey(
    
    name: r'committedDate',
    required: false,
    includeIfNull: false,
  )


  final DateTime? committedDate;



  @JsonKey(
    
    name: r'parents',
    required: true,
    includeIfNull: false,
  )


  final List<String> parents;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'add',
    required: true,
    includeIfNull: false,
  )


  final int add;



  @JsonKey(
    
    name: r'del',
    required: true,
    includeIfNull: false,
  )


  final int del;



  @JsonKey(
    
    name: r'files',
    required: true,
    includeIfNull: false,
  )


  final List<FileChange> files;



      /// More files changed than are listed
  @JsonKey(
    
    name: r'filesCapped',
    required: false,
    includeIfNull: false,
  )


  final bool? filesCapped;



  @JsonKey(
    
    name: r'pipelines',
    required: true,
    includeIfNull: false,
  )


  final List<Pipeline> pipelines;



  @JsonKey(
    
    name: r'pulls',
    required: true,
    includeIfNull: false,
  )


  final List<CommitPull> pulls;



  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;



  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final CommitDetailProviderEnum provider;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommitDetail &&
      other.sha == sha &&
      other.message == message &&
      other.author == author &&
      other.authorEmail == authorEmail &&
      other.authorLogin == authorLogin &&
      other.authorAvatar == authorAvatar &&
      other.date == date &&
      other.committer == committer &&
      other.committerEmail == committerEmail &&
      other.committedDate == committedDate &&
      other.parents == parents &&
      other.url == url &&
      other.add == add &&
      other.del == del &&
      other.files == files &&
      other.filesCapped == filesCapped &&
      other.pipelines == pipelines &&
      other.pulls == pulls &&
      other.ticketKey == ticketKey &&
      other.provider == provider;

    @override
    int get hashCode =>
        sha.hashCode +
        message.hashCode +
        author.hashCode +
        authorEmail.hashCode +
        authorLogin.hashCode +
        authorAvatar.hashCode +
        date.hashCode +
        committer.hashCode +
        committerEmail.hashCode +
        committedDate.hashCode +
        parents.hashCode +
        url.hashCode +
        add.hashCode +
        del.hashCode +
        files.hashCode +
        filesCapped.hashCode +
        pipelines.hashCode +
        pulls.hashCode +
        ticketKey.hashCode +
        provider.hashCode;

  factory CommitDetail.fromJson(Map<String, dynamic> json) => _$CommitDetailFromJson(json);

  Map<String, dynamic> toJson() => _$CommitDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum CommitDetailProviderEnum {
@JsonValue(r'github')
github(r'github'),
@JsonValue(r'gitlab')
gitlab(r'gitlab');

const CommitDetailProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


