//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/rule_enforce.dart';
import 'package:agnts_api/src/model/rule_kind.dart';
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

     this.kind,

     this.enforce,

     this.removeEnforce,

     this.delivery,
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



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final RuleKind? kind;



  @JsonKey(
    
    name: r'enforce',
    required: false,
    includeIfNull: false,
  )


  final RuleEnforce? enforce;



      /// Remove the enforcement; enforce left out keeps it
  @JsonKey(
    
    name: r'removeEnforce',
    required: false,
    includeIfNull: false,
  )


  final bool? removeEnforce;



      /// Left out keeps the rule's
  @JsonKey(
    
    name: r'delivery',
    required: false,
    includeIfNull: false,
  )


  final RuleInputDeliveryEnum? delivery;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RuleInput &&
      other.title == title &&
      other.body == body &&
      other.repoId == repoId &&
      other.enabled == enabled &&
      other.kind == kind &&
      other.enforce == enforce &&
      other.removeEnforce == removeEnforce &&
      other.delivery == delivery;

    @override
    int get hashCode =>
        title.hashCode +
        body.hashCode +
        repoId.hashCode +
        enabled.hashCode +
        kind.hashCode +
        enforce.hashCode +
        removeEnforce.hashCode +
        delivery.hashCode;

  factory RuleInput.fromJson(Map<String, dynamic> json) => _$RuleInputFromJson(json);

  Map<String, dynamic> toJson() => _$RuleInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Left out keeps the rule's
enum RuleInputDeliveryEnum {
@JsonValue(r'prompt')
prompt(r'prompt'),
@JsonValue(r'skill')
skill(r'skill');

const RuleInputDeliveryEnum(this.value);

final String value;

@override
String toString() => value;
}


