//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ticket_repos_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TicketReposInput {
  /// Returns a new [TicketReposInput] instance.
  TicketReposInput({

     this.repoIds,

     this.groupId,
  });

  @JsonKey(
    
    name: r'repoIds',
    required: false,
    includeIfNull: false,
  )


  final List<int>? repoIds;



  @JsonKey(
    
    name: r'groupId',
    required: false,
    includeIfNull: false,
  )


  final int? groupId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TicketReposInput &&
      other.repoIds == repoIds &&
      other.groupId == groupId;

    @override
    int get hashCode =>
        repoIds.hashCode +
        groupId.hashCode;

  factory TicketReposInput.fromJson(Map<String, dynamic> json) => _$TicketReposInputFromJson(json);

  Map<String, dynamic> toJson() => _$TicketReposInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

