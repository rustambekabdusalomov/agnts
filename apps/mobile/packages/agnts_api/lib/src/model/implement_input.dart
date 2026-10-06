//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'implement_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImplementInput {
  /// Returns a new [ImplementInput] instance.
  ImplementInput({

     this.repoId,

     this.start,
  });

      /// Where to implement it; defaults to the report's repository
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



      /// code = start now without questions (default), queue = keep until started
  @JsonKey(
    
    name: r'start',
    required: false,
    includeIfNull: false,
  )


  final ImplementInputStartEnum? start;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImplementInput &&
      other.repoId == repoId &&
      other.start == start;

    @override
    int get hashCode =>
        repoId.hashCode +
        start.hashCode;

  factory ImplementInput.fromJson(Map<String, dynamic> json) => _$ImplementInputFromJson(json);

  Map<String, dynamic> toJson() => _$ImplementInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// code = start now without questions (default), queue = keep until started
enum ImplementInputStartEnum {
@JsonValue(r'code')
code(r'code'),
@JsonValue(r'queue')
queue(r'queue');

const ImplementInputStartEnum(this.value);

final String value;

@override
String toString() => value;
}


