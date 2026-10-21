//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_brief_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoBriefInput {
  /// Returns a new [RepoBriefInput] instance.
  RepoBriefInput({

    required  this.body,

     this.architecture,
  });

  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



      /// Replaces the approved architecture.json when given; empty removes it
  @JsonKey(
    
    name: r'architecture',
    required: false,
    includeIfNull: false,
  )


  final String? architecture;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoBriefInput &&
      other.body == body &&
      other.architecture == architecture;

    @override
    int get hashCode =>
        body.hashCode +
        architecture.hashCode;

  factory RepoBriefInput.fromJson(Map<String, dynamic> json) => _$RepoBriefInputFromJson(json);

  Map<String, dynamic> toJson() => _$RepoBriefInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

