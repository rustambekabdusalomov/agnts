//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'published_review.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublishedReview {
  /// Returns a new [PublishedReview] instance.
  PublishedReview({

    required  this.ticket,

    required  this.summary,

    required  this.inline,

    required  this.still,

    required  this.resolved,
  });

  @JsonKey(
    
    name: r'ticket',
    required: true,
    includeIfNull: false,
  )


  final Ticket ticket;



  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final PublishedReviewSummaryEnum summary;



      /// Comments posted on their lines
  @JsonKey(
    
    name: r'inline',
    required: true,
    includeIfNull: false,
  )


  final int inline;



      /// Findings agnts posted before that are still there (answered in their threads)
  @JsonKey(
    
    name: r'still',
    required: true,
    includeIfNull: false,
  )


  final int still;



      /// Findings agnts posted before that are gone (answered and resolved)
  @JsonKey(
    
    name: r'resolved',
    required: true,
    includeIfNull: false,
  )


  final int resolved;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublishedReview &&
      other.ticket == ticket &&
      other.summary == summary &&
      other.inline == inline &&
      other.still == still &&
      other.resolved == resolved;

    @override
    int get hashCode =>
        ticket.hashCode +
        summary.hashCode +
        inline.hashCode +
        still.hashCode +
        resolved.hashCode;

  factory PublishedReview.fromJson(Map<String, dynamic> json) => _$PublishedReviewFromJson(json);

  Map<String, dynamic> toJson() => _$PublishedReviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PublishedReviewSummaryEnum {
@JsonValue(r'')
empty(r''),
@JsonValue(r'posted')
posted(r'posted'),
@JsonValue(r'edited')
edited(r'edited');

const PublishedReviewSummaryEnum(this.value);

final String value;

@override
String toString() => value;
}


