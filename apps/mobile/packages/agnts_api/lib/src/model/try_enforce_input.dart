//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/rule_enforce.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'try_enforce_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TryEnforceInput {
  /// Returns a new [TryEnforceInput] instance.
  TryEnforceInput({

    required  this.enforce,

     this.repoId,
  });

  @JsonKey(
    
    name: r'enforce',
    required: true,
    includeIfNull: false,
  )


  final RuleEnforce enforce;



      /// Leave out to check every repository
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TryEnforceInput &&
      other.enforce == enforce &&
      other.repoId == repoId;

    @override
    int get hashCode =>
        enforce.hashCode +
        repoId.hashCode;

  factory TryEnforceInput.fromJson(Map<String, dynamic> json) => _$TryEnforceInputFromJson(json);

  Map<String, dynamic> toJson() => _$TryEnforceInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

