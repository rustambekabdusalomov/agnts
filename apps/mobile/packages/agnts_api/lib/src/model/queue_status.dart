//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/queue_status_waiting.dart';
import 'package:agnts_api/src/model/queue_status_server_queue_inner.dart';
import 'package:agnts_api/src/model/capacity.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'queue_status.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QueueStatus {
  /// Returns a new [QueueStatus] instance.
  QueueStatus({

    required  this.running,

    required  this.slots,

    required  this.waiting,

    required  this.serverQueue,

    required  this.serverQueueLength,

    required  this.capacity,
  });

  @JsonKey(
    
    name: r'running',
    required: true,
    includeIfNull: false,
  )


  final int running;



  @JsonKey(
    
    name: r'slots',
    required: true,
    includeIfNull: false,
  )


  final int slots;



  @JsonKey(
    
    name: r'waiting',
    required: true,
    includeIfNull: false,
  )


  final QueueStatusWaiting waiting;



      /// The workspace's tickets waiting for the server
  @JsonKey(
    
    name: r'serverQueue',
    required: true,
    includeIfNull: false,
  )


  final List<QueueStatusServerQueueInner> serverQueue;



  @JsonKey(
    
    name: r'serverQueueLength',
    required: true,
    includeIfNull: false,
  )


  final int serverQueueLength;



  @JsonKey(
    
    name: r'capacity',
    required: true,
    includeIfNull: false,
  )


  final Capacity capacity;





    @override
    bool operator ==(Object other) => identical(this, other) || other is QueueStatus &&
      other.running == running &&
      other.slots == slots &&
      other.waiting == waiting &&
      other.serverQueue == serverQueue &&
      other.serverQueueLength == serverQueueLength &&
      other.capacity == capacity;

    @override
    int get hashCode =>
        running.hashCode +
        slots.hashCode +
        waiting.hashCode +
        serverQueue.hashCode +
        serverQueueLength.hashCode +
        capacity.hashCode;

  factory QueueStatus.fromJson(Map<String, dynamic> json) => _$QueueStatusFromJson(json);

  Map<String, dynamic> toJson() => _$QueueStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

