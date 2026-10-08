//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'queue_status_server_queue_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QueueStatusServerQueueInner {
  /// Returns a new [QueueStatusServerQueueInner] instance.
  QueueStatusServerQueueInner({

    required  this.key,

    required  this.position,

    required  this.others,

     this.estimateSec,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



      /// 1-based place in the whole server queue
  @JsonKey(
    
    name: r'position',
    required: true,
    includeIfNull: false,
  )


  final int position;



      /// Tickets of other workspaces ahead
  @JsonKey(
    
    name: r'others',
    required: true,
    includeIfNull: false,
  )


  final int others;



      /// About how long until it may start
  @JsonKey(
    
    name: r'estimateSec',
    required: false,
    includeIfNull: false,
  )


  final int? estimateSec;





    @override
    bool operator ==(Object other) => identical(this, other) || other is QueueStatusServerQueueInner &&
      other.key == key &&
      other.position == position &&
      other.others == others &&
      other.estimateSec == estimateSec;

    @override
    int get hashCode =>
        key.hashCode +
        position.hashCode +
        others.hashCode +
        estimateSec.hashCode;

  factory QueueStatusServerQueueInner.fromJson(Map<String, dynamic> json) => _$QueueStatusServerQueueInnerFromJson(json);

  Map<String, dynamic> toJson() => _$QueueStatusServerQueueInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

