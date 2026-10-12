//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson_count.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LessonCount {
  /// Returns a new [LessonCount] instance.
  LessonCount({

    required  this.category,

    required  this.created,

    required  this.learned,
  });

  @JsonKey(
    
    name: r'category',
    required: true,
    includeIfNull: false,
  )


  final String category;



  @JsonKey(
    
    name: r'created',
    required: true,
    includeIfNull: false,
  )


  final int created;



  @JsonKey(
    
    name: r'learned',
    required: true,
    includeIfNull: false,
  )


  final int learned;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LessonCount &&
      other.category == category &&
      other.created == created &&
      other.learned == learned;

    @override
    int get hashCode =>
        category.hashCode +
        created.hashCode +
        learned.hashCode;

  factory LessonCount.fromJson(Map<String, dynamic> json) => _$LessonCountFromJson(json);

  Map<String, dynamic> toJson() => _$LessonCountToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

