//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_enforce.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RuleEnforce {
  /// Returns a new [RuleEnforce] instance.
  RuleEnforce({

    required  this.on_,

     this.paths,

     this.pattern,

    required  this.action,

     this.message,
  });

  @JsonKey(
    
    name: r'on',
    required: true,
    includeIfNull: false,
  )


  final RuleEnforceOn_Enum on_;



  @JsonKey(
    
    name: r'paths',
    required: false,
    includeIfNull: false,
  )


  final List<String>? paths;



      /// A regular expression (RE2)
  @JsonKey(
    
    name: r'pattern',
    required: false,
    includeIfNull: false,
  )


  final String? pattern;



  @JsonKey(
    
    name: r'action',
    required: true,
    includeIfNull: false,
  )


  final RuleEnforceActionEnum action;



  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RuleEnforce &&
      other.on_ == on_ &&
      other.paths == paths &&
      other.pattern == pattern &&
      other.action == action &&
      other.message == message;

    @override
    int get hashCode =>
        on_.hashCode +
        paths.hashCode +
        pattern.hashCode +
        action.hashCode +
        message.hashCode;

  factory RuleEnforce.fromJson(Map<String, dynamic> json) => _$RuleEnforceFromJson(json);

  Map<String, dynamic> toJson() => _$RuleEnforceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum RuleEnforceOn_Enum {
@JsonValue(r'file')
file(r'file'),
@JsonValue(r'bash')
bash(r'bash'),
@JsonValue(r'diff')
diff(r'diff');

const RuleEnforceOn_Enum(this.value);

final String value;

@override
String toString() => value;
}


enum RuleEnforceActionEnum {
@JsonValue(r'block')
block(r'block'),
@JsonValue(r'warn')
warn(r'warn');

const RuleEnforceActionEnum(this.value);

final String value;

@override
String toString() => value;
}


