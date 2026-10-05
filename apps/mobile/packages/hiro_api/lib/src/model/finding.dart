//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'finding.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Finding {
  /// Returns a new [Finding] instance.
  Finding({

    required  this.severity,

    required  this.category,

     this.file,

     this.line,

    required  this.title,

     this.detail,

     this.suggestion,
  });

  @JsonKey(
    
    name: r'severity',
    required: true,
    includeIfNull: false,
  )


  final FindingSeverityEnum severity;



  @JsonKey(
    
    name: r'category',
    required: true,
    includeIfNull: false,
  )


  final FindingCategoryEnum category;



      /// Path relative to the repository
  @JsonKey(
    
    name: r'file',
    required: false,
    includeIfNull: false,
  )


  final String? file;



  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'detail',
    required: false,
    includeIfNull: false,
  )


  final String? detail;



      /// What to change, written to be sent back as feedback
  @JsonKey(
    
    name: r'suggestion',
    required: false,
    includeIfNull: false,
  )


  final String? suggestion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Finding &&
      other.severity == severity &&
      other.category == category &&
      other.file == file &&
      other.line == line &&
      other.title == title &&
      other.detail == detail &&
      other.suggestion == suggestion;

    @override
    int get hashCode =>
        severity.hashCode +
        category.hashCode +
        file.hashCode +
        line.hashCode +
        title.hashCode +
        detail.hashCode +
        suggestion.hashCode;

  factory Finding.fromJson(Map<String, dynamic> json) => _$FindingFromJson(json);

  Map<String, dynamic> toJson() => _$FindingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum FindingSeverityEnum {
@JsonValue(r'blocker')
blocker(r'blocker'),
@JsonValue(r'major')
major(r'major'),
@JsonValue(r'minor')
minor(r'minor'),
@JsonValue(r'nit')
nit(r'nit');

const FindingSeverityEnum(this.value);

final String value;

@override
String toString() => value;
}


enum FindingCategoryEnum {
@JsonValue(r'correctness')
correctness(r'correctness'),
@JsonValue(r'security')
security(r'security'),
@JsonValue(r'performance')
performance(r'performance'),
@JsonValue(r'tests')
tests(r'tests'),
@JsonValue(r'rules')
rules(r'rules'),
@JsonValue(r'maintainability')
maintainability(r'maintainability'),
@JsonValue(r'accuracy')
accuracy(r'accuracy'),
@JsonValue(r'completeness')
completeness(r'completeness'),
@JsonValue(r'other')
other(r'other');

const FindingCategoryEnum(this.value);

final String value;

@override
String toString() => value;
}


