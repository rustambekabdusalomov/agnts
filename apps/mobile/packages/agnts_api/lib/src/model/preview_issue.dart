//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preview_issue.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PreviewIssue {
  /// Returns a new [PreviewIssue] instance.
  PreviewIssue({

    required  this.severity,

    required  this.description,

     this.shotId,
  });

  @JsonKey(
    
    name: r'severity',
    required: true,
    includeIfNull: false,
  )


  final PreviewIssueSeverityEnum severity;



  @JsonKey(
    
    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



  @JsonKey(
    
    name: r'shotId',
    required: false,
    includeIfNull: false,
  )


  final String? shotId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PreviewIssue &&
      other.severity == severity &&
      other.description == description &&
      other.shotId == shotId;

    @override
    int get hashCode =>
        severity.hashCode +
        description.hashCode +
        shotId.hashCode;

  factory PreviewIssue.fromJson(Map<String, dynamic> json) => _$PreviewIssueFromJson(json);

  Map<String, dynamic> toJson() => _$PreviewIssueToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PreviewIssueSeverityEnum {
@JsonValue(r'high')
high(r'high'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'low')
low(r'low');

const PreviewIssueSeverityEnum(this.value);

final String value;

@override
String toString() => value;
}


