//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'red_flag.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RedFlag {
  /// Returns a new [RedFlag] instance.
  RedFlag({

    required  this.kind,

    required  this.path,

     this.line,

    required  this.text,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final RedFlagKindEnum kind;



  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



      /// Line in the new file; absent for the whole file
  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



  @JsonKey(
    
    name: r'text',
    required: true,
    includeIfNull: false,
  )


  final String text;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RedFlag &&
      other.kind == kind &&
      other.path == path &&
      other.line == line &&
      other.text == text;

    @override
    int get hashCode =>
        kind.hashCode +
        path.hashCode +
        line.hashCode +
        text.hashCode;

  factory RedFlag.fromJson(Map<String, dynamic> json) => _$RedFlagFromJson(json);

  Map<String, dynamic> toJson() => _$RedFlagToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum RedFlagKindEnum {
@JsonValue(r'skipped_test')
skippedTest(r'skipped_test'),
@JsonValue(r'removed_assertion')
removedAssertion(r'removed_assertion'),
@JsonValue(r'deleted_test')
deletedTest(r'deleted_test'),
@JsonValue(r'silenced_lint')
silencedLint(r'silenced_lint'),
@JsonValue(r'swallowed_error')
swallowedError(r'swallowed_error'),
@JsonValue(r'todo')
todo(r'todo'),
@JsonValue(r'new_dependency')
newDependency(r'new_dependency');

const RedFlagKindEnum(this.value);

final String value;

@override
String toString() => value;
}


