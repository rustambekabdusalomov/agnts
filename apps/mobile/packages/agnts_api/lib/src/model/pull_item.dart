//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pull_item.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullItem {
  /// Returns a new [PullItem] instance.
  PullItem({

    required  this.number,

    required  this.url,

    required  this.title,

    required  this.author,

    required  this.headRef,

    required  this.headSha,

    required  this.baseRef,

    required  this.draft,

    required  this.state,

    required  this.why,

    required  this.updatedAt,

     this.ticketKey,

    required  this.own,
  });

      /// The pull request number (GitLab: the IID)
  @JsonKey(
    
    name: r'number',
    required: true,
    includeIfNull: false,
  )


  final int number;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'author',
    required: true,
    includeIfNull: false,
  )


  final String author;



  @JsonKey(
    
    name: r'headRef',
    required: true,
    includeIfNull: false,
  )


  final String headRef;



  @JsonKey(
    
    name: r'headSha',
    required: true,
    includeIfNull: false,
  )


  final String headSha;



  @JsonKey(
    
    name: r'baseRef',
    required: true,
    includeIfNull: false,
  )


  final String baseRef;



  @JsonKey(
    
    name: r'draft',
    required: true,
    includeIfNull: false,
  )


  final bool draft;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final PullItemStateEnum state;



      /// Why it waits for the token's user: assigned, review_requested, or empty; manual for a review someone asked for from the pull request page
  @JsonKey(
    
    name: r'why',
    required: true,
    includeIfNull: false,
  )


  final String why;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;



      /// agnts's ticket for it: its own change, or its review
  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;



      /// It is agnts's own change
  @JsonKey(
    
    name: r'own',
    required: true,
    includeIfNull: false,
  )


  final bool own;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullItem &&
      other.number == number &&
      other.url == url &&
      other.title == title &&
      other.author == author &&
      other.headRef == headRef &&
      other.headSha == headSha &&
      other.baseRef == baseRef &&
      other.draft == draft &&
      other.state == state &&
      other.why == why &&
      other.updatedAt == updatedAt &&
      other.ticketKey == ticketKey &&
      other.own == own;

    @override
    int get hashCode =>
        number.hashCode +
        url.hashCode +
        title.hashCode +
        author.hashCode +
        headRef.hashCode +
        headSha.hashCode +
        baseRef.hashCode +
        draft.hashCode +
        state.hashCode +
        why.hashCode +
        updatedAt.hashCode +
        ticketKey.hashCode +
        own.hashCode;

  factory PullItem.fromJson(Map<String, dynamic> json) => _$PullItemFromJson(json);

  Map<String, dynamic> toJson() => _$PullItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PullItemStateEnum {
@JsonValue(r'open')
open(r'open'),
@JsonValue(r'closed')
closed(r'closed'),
@JsonValue(r'merged')
merged(r'merged');

const PullItemStateEnum(this.value);

final String value;

@override
String toString() => value;
}


