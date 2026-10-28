//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_grant.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_join.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingJoin {
  /// Returns a new [MeetingJoin] instance.
  MeetingJoin({

    required  this.status,

     this.grant,

     this.knockId,

     this.knockToken,

     this.guestToken,

     this.guestName,
  });

  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final MeetingJoinStatusEnum status;



  @JsonKey(
    
    name: r'grant',
    required: false,
    includeIfNull: false,
  )


  final MeetingGrant? grant;



  @JsonKey(
    
    name: r'knockId',
    required: false,
    includeIfNull: false,
  )


  final int? knockId;



      /// Send as X-Knock-Token when polling
  @JsonKey(
    
    name: r'knockToken',
    required: false,
    includeIfNull: false,
  )


  final String? knockToken;



      /// A new guest's token: keep it and send it as X-Guest-Token next time
  @JsonKey(
    
    name: r'guestToken',
    required: false,
    includeIfNull: false,
  )


  final String? guestToken;



  @JsonKey(
    
    name: r'guestName',
    required: false,
    includeIfNull: false,
  )


  final String? guestName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingJoin &&
      other.status == status &&
      other.grant == grant &&
      other.knockId == knockId &&
      other.knockToken == knockToken &&
      other.guestToken == guestToken &&
      other.guestName == guestName;

    @override
    int get hashCode =>
        status.hashCode +
        grant.hashCode +
        knockId.hashCode +
        knockToken.hashCode +
        guestToken.hashCode +
        guestName.hashCode;

  factory MeetingJoin.fromJson(Map<String, dynamic> json) => _$MeetingJoinFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingJoinToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MeetingJoinStatusEnum {
@JsonValue(r'joined')
joined(r'joined'),
@JsonValue(r'waiting')
waiting(r'waiting');

const MeetingJoinStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


