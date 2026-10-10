//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/reviewer_note.dart';
import 'package:agnts_api/src/model/reviewer.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reviewers.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Reviewers {
  /// Returns a new [Reviewers] instance.
  Reviewers({

    required  this.reviewers,

    required  this.notes,
  });

  @JsonKey(
    
    name: r'reviewers',
    required: true,
    includeIfNull: false,
  )


  final List<Reviewer> reviewers;



      /// The newest notes of everyone, newest first
  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: false,
  )


  final List<ReviewerNote> notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Reviewers &&
      other.reviewers == reviewers &&
      other.notes == notes;

    @override
    int get hashCode =>
        reviewers.hashCode +
        notes.hashCode;

  factory Reviewers.fromJson(Map<String, dynamic> json) => _$ReviewersFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewersToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

