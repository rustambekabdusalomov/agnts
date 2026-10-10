//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/reviewer_note.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reviewer.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Reviewer {
  /// Returns a new [Reviewer] instance.
  Reviewer({

    required  this.login,

    required  this.profile,

    required  this.notesFolded,

     this.updatedAt,

    required  this.pending,
  });

  @JsonKey(
    
    name: r'login',
    required: true,
    includeIfNull: false,
  )


  final String login;



      /// Markdown; empty until a review folds notes in or someone writes it
  @JsonKey(
    
    name: r'profile',
    required: true,
    includeIfNull: false,
  )


  final String profile;



      /// Notes folded into the profile so far
  @JsonKey(
    
    name: r'notesFolded',
    required: true,
    includeIfNull: false,
  )


  final int notesFolded;



  @JsonKey(
    
    name: r'updatedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updatedAt;



      /// Notes the next review folds in, newest first
  @JsonKey(
    
    name: r'pending',
    required: true,
    includeIfNull: false,
  )


  final List<ReviewerNote> pending;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Reviewer &&
      other.login == login &&
      other.profile == profile &&
      other.notesFolded == notesFolded &&
      other.updatedAt == updatedAt &&
      other.pending == pending;

    @override
    int get hashCode =>
        login.hashCode +
        profile.hashCode +
        notesFolded.hashCode +
        updatedAt.hashCode +
        pending.hashCode;

  factory Reviewer.fromJson(Map<String, dynamic> json) => _$ReviewerFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

