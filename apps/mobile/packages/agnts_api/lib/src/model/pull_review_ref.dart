//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pull_review_ref.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullReviewRef {
  /// Returns a new [PullReviewRef] instance.
  PullReviewRef({

    required  this.key,

    required  this.state,

     this.headSha,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final TicketState state;



      /// The commit it reviewed, once reviewed
  @JsonKey(
    
    name: r'headSha',
    required: false,
    includeIfNull: false,
  )


  final String? headSha;



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
    bool operator ==(Object other) => identical(this, other) || other is PullReviewRef &&
      other.key == key &&
      other.state == state &&
      other.headSha == headSha &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        key.hashCode +
        state.hashCode +
        headSha.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory PullReviewRef.fromJson(Map<String, dynamic> json) => _$PullReviewRefFromJson(json);

  Map<String, dynamic> toJson() => _$PullReviewRefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

