//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/lesson_brief.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson_list.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LessonList {
  /// Returns a new [LessonList] instance.
  LessonList({

    required  this.items,

    required  this.total,

    required  this.unlearned,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<LessonBrief> items;



      /// All lessons, ignoring filters
  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final int total;



      /// Lessons not learned yet, ignoring filters
  @JsonKey(
    
    name: r'unlearned',
    required: true,
    includeIfNull: false,
  )


  final int unlearned;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LessonList &&
      other.items == items &&
      other.total == total &&
      other.unlearned == unlearned;

    @override
    int get hashCode =>
        items.hashCode +
        total.hashCode +
        unlearned.hashCode;

  factory LessonList.fromJson(Map<String, dynamic> json) => _$LessonListFromJson(json);

  Map<String, dynamic> toJson() => _$LessonListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

