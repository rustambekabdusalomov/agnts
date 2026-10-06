//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RuleInput {
  /// Returns a new [RuleInput] instance.
  RuleInput({

    required  this.title,

    required  this.body,

     this.repoId,

     this.enabled = true,
  });

  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



      /// Leave out for a rule every repository follows
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



  @JsonKey(
    defaultValue: true,
    name: r'enabled',
    required: false,
    includeIfNull: false,
  )


  final bool? enabled;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RuleInput &&
      other.title == title &&
      other.body == body &&
      other.repoId == repoId &&
      other.enabled == enabled;

    @override
    int get hashCode =>
        title.hashCode +
        body.hashCode +
        repoId.hashCode +
        enabled.hashCode;

  factory RuleInput.fromJson(Map<String, dynamic> json) => _$RuleInputFromJson(json);

  Map<String, dynamic> toJson() => _$RuleInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

