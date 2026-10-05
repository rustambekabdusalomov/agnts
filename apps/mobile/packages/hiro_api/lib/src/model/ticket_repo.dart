//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ticket_repo.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TicketRepo {
  /// Returns a new [TicketRepo] instance.
  TicketRepo({

    required  this.repoId,
  });

  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TicketRepo &&
      other.repoId == repoId;

    @override
    int get hashCode =>
        repoId.hashCode;

  factory TicketRepo.fromJson(Map<String, dynamic> json) => _$TicketRepoFromJson(json);

  Map<String, dynamic> toJson() => _$TicketRepoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

