//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'code_approval.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CodeApproval {
  /// Returns a new [CodeApproval] instance.
  CodeApproval({

    required  this.id,

    required  this.conversationId,

    required  this.ticketKey,

    required  this.tool,

     this.command,

     this.path,

    required  this.reason,

    required  this.status,

    required  this.expiresAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'conversationId',
    required: true,
    includeIfNull: false,
  )


  final int conversationId;



  @JsonKey(
    
    name: r'ticketKey',
    required: true,
    includeIfNull: false,
  )


  final String ticketKey;



  @JsonKey(
    
    name: r'tool',
    required: true,
    includeIfNull: false,
  )


  final String tool;



  @JsonKey(
    
    name: r'command',
    required: false,
    includeIfNull: false,
  )


  final String? command;



  @JsonKey(
    
    name: r'path',
    required: false,
    includeIfNull: false,
  )


  final String? path;



      /// Why a rule asks about it
  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CodeApprovalStatusEnum status;



  @JsonKey(
    
    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CodeApproval &&
      other.id == id &&
      other.conversationId == conversationId &&
      other.ticketKey == ticketKey &&
      other.tool == tool &&
      other.command == command &&
      other.path == path &&
      other.reason == reason &&
      other.status == status &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        id.hashCode +
        conversationId.hashCode +
        ticketKey.hashCode +
        tool.hashCode +
        command.hashCode +
        path.hashCode +
        reason.hashCode +
        status.hashCode +
        expiresAt.hashCode;

  factory CodeApproval.fromJson(Map<String, dynamic> json) => _$CodeApprovalFromJson(json);

  Map<String, dynamic> toJson() => _$CodeApprovalToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum CodeApprovalStatusEnum {
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'allowed')
allowed(r'allowed'),
@JsonValue(r'denied')
denied(r'denied'),
@JsonValue(r'expired')
expired(r'expired');

const CodeApprovalStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


