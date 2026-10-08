//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/invite.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_invite201_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateInvite201Response {
  /// Returns a new [CreateInvite201Response] instance.
  CreateInvite201Response({

    required  this.invite,

    required  this.url,

     this.emailed,
  });

  @JsonKey(
    
    name: r'invite',
    required: true,
    includeIfNull: false,
  )


  final Invite invite;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'emailed',
    required: false,
    includeIfNull: false,
  )


  final bool? emailed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateInvite201Response &&
      other.invite == invite &&
      other.url == url &&
      other.emailed == emailed;

    @override
    int get hashCode =>
        invite.hashCode +
        url.hashCode +
        emailed.hashCode;

  factory CreateInvite201Response.fromJson(Map<String, dynamic> json) => _$CreateInvite201ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateInvite201ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

