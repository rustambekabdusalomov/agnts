//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson_ref.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LessonRef {
  /// Returns a new [LessonRef] instance.
  LessonRef({

    required  this.path,

     this.line,

     this.note,
  });

      /// Relative to the repository root
  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LessonRef &&
      other.path == path &&
      other.line == line &&
      other.note == note;

    @override
    int get hashCode =>
        path.hashCode +
        line.hashCode +
        note.hashCode;

  factory LessonRef.fromJson(Map<String, dynamic> json) => _$LessonRefFromJson(json);

  Map<String, dynamic> toJson() => _$LessonRefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

