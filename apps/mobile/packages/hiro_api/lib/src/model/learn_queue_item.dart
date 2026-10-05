//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'learn_queue_item.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LearnQueueItem {
  /// Returns a new [LearnQueueItem] instance.
  LearnQueueItem({

    required  this.key,

    required  this.title,

    required  this.repoName,

    required  this.status,

    required  this.lessons,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'repoName',
    required: true,
    includeIfNull: false,
  )


  final String repoName;



      /// none: the ticket was never learned from
  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final LearnQueueItemStatusEnum status;



      /// Lessons it produced so far
  @JsonKey(
    
    name: r'lessons',
    required: true,
    includeIfNull: false,
  )


  final int lessons;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LearnQueueItem &&
      other.key == key &&
      other.title == title &&
      other.repoName == repoName &&
      other.status == status &&
      other.lessons == lessons &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        key.hashCode +
        title.hashCode +
        repoName.hashCode +
        status.hashCode +
        lessons.hashCode +
        updatedAt.hashCode;

  factory LearnQueueItem.fromJson(Map<String, dynamic> json) => _$LearnQueueItemFromJson(json);

  Map<String, dynamic> toJson() => _$LearnQueueItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// none: the ticket was never learned from
enum LearnQueueItemStatusEnum {
@JsonValue(r'running')
running(r'running'),
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'failed')
failed(r'failed'),
@JsonValue(r'none')
none(r'none');

const LearnQueueItemStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


