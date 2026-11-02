//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/log_severity.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_pattern.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogPattern {
  /// Returns a new [LogPattern] instance.
  LogPattern({

    required  this.name,

    required  this.pattern,

    required  this.category,

    required  this.severity,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



      /// A regular expression (RE2, case-insensitive)
  @JsonKey(
    
    name: r'pattern',
    required: true,
    includeIfNull: false,
  )


  final String pattern;



  @JsonKey(
    
    name: r'category',
    required: true,
    includeIfNull: false,
  )


  final LogPatternCategoryEnum category;



  @JsonKey(
    
    name: r'severity',
    required: true,
    includeIfNull: false,
  )


  final LogSeverity severity;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogPattern &&
      other.name == name &&
      other.pattern == pattern &&
      other.category == category &&
      other.severity == severity;

    @override
    int get hashCode =>
        name.hashCode +
        pattern.hashCode +
        category.hashCode +
        severity.hashCode;

  factory LogPattern.fromJson(Map<String, dynamic> json) => _$LogPatternFromJson(json);

  Map<String, dynamic> toJson() => _$LogPatternToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum LogPatternCategoryEnum {
@JsonValue(r'error')
error(r'error'),
@JsonValue(r'security')
security(r'security');

const LogPatternCategoryEnum(this.value);

final String value;

@override
String toString() => value;
}


