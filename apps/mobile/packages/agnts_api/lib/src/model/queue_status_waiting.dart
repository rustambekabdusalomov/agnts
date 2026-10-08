//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'queue_status_waiting.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QueueStatusWaiting {
  /// Returns a new [QueueStatusWaiting] instance.
  QueueStatusWaiting({

     this.blocked,

     this.slots,

     this.server,

     this.claude,
  });

  @JsonKey(
    
    name: r'blocked',
    required: false,
    includeIfNull: false,
  )


  final int? blocked;



  @JsonKey(
    
    name: r'slots',
    required: false,
    includeIfNull: false,
  )


  final int? slots;



  @JsonKey(
    
    name: r'server',
    required: false,
    includeIfNull: false,
  )


  final int? server;



  @JsonKey(
    
    name: r'claude',
    required: false,
    includeIfNull: false,
  )


  final int? claude;





    @override
    bool operator ==(Object other) => identical(this, other) || other is QueueStatusWaiting &&
      other.blocked == blocked &&
      other.slots == slots &&
      other.server == server &&
      other.claude == claude;

    @override
    int get hashCode =>
        blocked.hashCode +
        slots.hashCode +
        server.hashCode +
        claude.hashCode;

  factory QueueStatusWaiting.fromJson(Map<String, dynamic> json) => _$QueueStatusWaitingFromJson(json);

  Map<String, dynamic> toJson() => _$QueueStatusWaitingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

