//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_invites.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_invitees_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingInviteesInput {
  /// Returns a new [MeetingInviteesInput] instance.
  MeetingInviteesInput({

     this.add,

     this.remove,
  });

  @JsonKey(
    
    name: r'add',
    required: false,
    includeIfNull: false,
  )


  final MeetingInvites? add;



      /// Invitee ids to uninvite
  @JsonKey(
    
    name: r'remove',
    required: false,
    includeIfNull: false,
  )


  final List<int>? remove;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingInviteesInput &&
      other.add == add &&
      other.remove == remove;

    @override
    int get hashCode =>
        add.hashCode +
        remove.hashCode;

  factory MeetingInviteesInput.fromJson(Map<String, dynamic> json) => _$MeetingInviteesInputFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingInviteesInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

