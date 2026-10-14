//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_rating.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantRating {
  /// Returns a new [AssistantRating] instance.
  AssistantRating({

    required  this.rating,

     this.comment,

     this.share,
  });

  @JsonKey(
    
    name: r'rating',
    required: true,
    includeIfNull: false,
  )


  final AssistantRatingRatingEnum rating;



  @JsonKey(
    
    name: r'comment',
    required: false,
    includeIfNull: false,
  )


  final String? comment;



      /// Keep the answer's snapshot so new prompts can be tried on it
  @JsonKey(
    
    name: r'share',
    required: false,
    includeIfNull: false,
  )


  final bool? share;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantRating &&
      other.rating == rating &&
      other.comment == comment &&
      other.share == share;

    @override
    int get hashCode =>
        rating.hashCode +
        comment.hashCode +
        share.hashCode;

  factory AssistantRating.fromJson(Map<String, dynamic> json) => _$AssistantRatingFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantRatingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AssistantRatingRatingEnum {
@JsonValue(-1)
numberNegative1('-1'),
@JsonValue(0)
number0('0'),
@JsonValue(1)
number1('1');

const AssistantRatingRatingEnum(this.value);

final String value;

@override
String toString() => value;
}


