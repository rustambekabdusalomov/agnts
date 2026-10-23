//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_comment.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentComment {
  /// Returns a new [DocumentComment] instance.
  DocumentComment({

    required  this.id,

     this.parentId,

    required  this.authorName,

    required  this.authorKind,

     this.authorVia,

     this.authorEmail,

    required  this.body,

    required  this.quote,

    required  this.prefix,

    required  this.suffix,

     this.slide,

    required  this.version,

     this.resolvedAt,

     this.resolvedBy,

    required  this.mine,

    required  this.canResolve,

    required  this.canDelete,

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
    
    name: r'parentId',
    required: false,
    includeIfNull: false,
  )


  final int? parentId;



  @JsonKey(
    
    name: r'authorName',
    required: true,
    includeIfNull: false,
  )


  final String authorName;



      /// gone when the member or guest no longer exists
  @JsonKey(
    
    name: r'authorKind',
    required: true,
    includeIfNull: false,
  )


  final DocumentCommentAuthorKindEnum authorKind;



      /// How a guest said who they are: a typed name, Google, or their agnts account
  @JsonKey(
    
    name: r'authorVia',
    required: false,
    includeIfNull: false,
  )


  final DocumentCommentAuthorViaEnum? authorVia;



      /// The email Google or an account gave for a guest; members only see it
  @JsonKey(
    
    name: r'authorEmail',
    required: false,
    includeIfNull: false,
  )


  final String? authorEmail;



  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



  @JsonKey(
    
    name: r'quote',
    required: true,
    includeIfNull: false,
  )


  final String quote;



  @JsonKey(
    
    name: r'prefix',
    required: true,
    includeIfNull: false,
  )


  final String prefix;



  @JsonKey(
    
    name: r'suffix',
    required: true,
    includeIfNull: false,
  )


  final String suffix;



      /// The slide, from 0, for slides
  @JsonKey(
    
    name: r'slide',
    required: false,
    includeIfNull: false,
  )


  final int? slide;



      /// The document's version when it was written
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(
    
    name: r'resolvedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? resolvedAt;



  @JsonKey(
    
    name: r'resolvedBy',
    required: false,
    includeIfNull: false,
  )


  final String? resolvedBy;



      /// You wrote it
  @JsonKey(
    
    name: r'mine',
    required: true,
    includeIfNull: false,
  )


  final bool mine;



      /// You may resolve or reopen this thread
  @JsonKey(
    
    name: r'canResolve',
    required: true,
    includeIfNull: false,
  )


  final bool canResolve;



  @JsonKey(
    
    name: r'canDelete',
    required: true,
    includeIfNull: false,
  )


  final bool canDelete;



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
    bool operator ==(Object other) => identical(this, other) || other is DocumentComment &&
      other.id == id &&
      other.parentId == parentId &&
      other.authorName == authorName &&
      other.authorKind == authorKind &&
      other.authorVia == authorVia &&
      other.authorEmail == authorEmail &&
      other.body == body &&
      other.quote == quote &&
      other.prefix == prefix &&
      other.suffix == suffix &&
      other.slide == slide &&
      other.version == version &&
      other.resolvedAt == resolvedAt &&
      other.resolvedBy == resolvedBy &&
      other.mine == mine &&
      other.canResolve == canResolve &&
      other.canDelete == canDelete &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        parentId.hashCode +
        authorName.hashCode +
        authorKind.hashCode +
        authorVia.hashCode +
        authorEmail.hashCode +
        body.hashCode +
        quote.hashCode +
        prefix.hashCode +
        suffix.hashCode +
        slide.hashCode +
        version.hashCode +
        resolvedAt.hashCode +
        resolvedBy.hashCode +
        mine.hashCode +
        canResolve.hashCode +
        canDelete.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory DocumentComment.fromJson(Map<String, dynamic> json) => _$DocumentCommentFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentCommentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// gone when the member or guest no longer exists
enum DocumentCommentAuthorKindEnum {
@JsonValue(r'member')
member(r'member'),
@JsonValue(r'guest')
guest(r'guest'),
@JsonValue(r'gone')
gone(r'gone');

const DocumentCommentAuthorKindEnum(this.value);

final String value;

@override
String toString() => value;
}


/// How a guest said who they are: a typed name, Google, or their agnts account
enum DocumentCommentAuthorViaEnum {
@JsonValue(r'name')
name(r'name'),
@JsonValue(r'google')
google(r'google'),
@JsonValue(r'account')
account(r'account');

const DocumentCommentAuthorViaEnum(this.value);

final String value;

@override
String toString() => value;
}


