//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'action_item_member_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActionItemMemberInput {
  /// Returns a new [ActionItemMemberInput] instance.
  ActionItemMemberInput({

    required  this.userId,
  });

      /// A member of the workspace
  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final int userId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActionItemMemberInput &&
      other.userId == userId;

    @override
    int get hashCode =>
        userId.hashCode;

  factory ActionItemMemberInput.fromJson(Map<String, dynamic> json) => _$ActionItemMemberInputFromJson(json);

  Map<String, dynamic> toJson() => _$ActionItemMemberInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

