//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_sync.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewSync {
  /// Returns a new [ReviewSync] instance.
  ReviewSync({

    required  this.repos,

    required  this.open,

    required  this.created,

    required  this.rereview,

    required  this.closed,

    required  this.errors,
  });

      /// Repositories asked
  @JsonKey(
    
    name: r'repos',
    required: true,
    includeIfNull: false,
  )


  final int repos;



      /// Pull requests waiting for you
  @JsonKey(
    
    name: r'open',
    required: true,
    includeIfNull: false,
  )


  final int open;



      /// New reviews queued
  @JsonKey(
    
    name: r'created',
    required: true,
    includeIfNull: false,
  )


  final int created;



      /// Reviews queued again for new commits
  @JsonKey(
    
    name: r'rereview',
    required: true,
    includeIfNull: false,
  )


  final int rereview;



      /// Reviews ended because the pull request was merged or closed on the git host
  @JsonKey(
    
    name: r'closed',
    required: true,
    includeIfNull: false,
  )


  final int closed;



      /// Repositories or pull requests that could not be read
  @JsonKey(
    
    name: r'errors',
    required: true,
    includeIfNull: false,
  )


  final List<String> errors;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewSync &&
      other.repos == repos &&
      other.open == open &&
      other.created == created &&
      other.rereview == rereview &&
      other.closed == closed &&
      other.errors == errors;

    @override
    int get hashCode =>
        repos.hashCode +
        open.hashCode +
        created.hashCode +
        rereview.hashCode +
        closed.hashCode +
        errors.hashCode;

  factory ReviewSync.fromJson(Map<String, dynamic> json) => _$ReviewSyncFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewSyncToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

