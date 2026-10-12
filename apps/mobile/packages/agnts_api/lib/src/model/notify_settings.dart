//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notify_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotifySettings {
  /// Returns a new [NotifySettings] instance.
  NotifySettings({

    required  this.push,

    required  this.telegram,

    required  this.needsYou,

    required  this.stopped,

    required  this.done,

     this.lessons,

     this.review,

     this.preview,

     this.previewPhotos,

     this.followUps,

     this.ci,
  });

  @JsonKey(
    
    name: r'push',
    required: true,
    includeIfNull: false,
  )


  final bool push;



  @JsonKey(
    
    name: r'telegram',
    required: true,
    includeIfNull: false,
  )


  final bool telegram;



  @JsonKey(
    
    name: r'needsYou',
    required: true,
    includeIfNull: false,
  )


  final bool needsYou;



  @JsonKey(
    
    name: r'stopped',
    required: true,
    includeIfNull: false,
  )


  final bool stopped;



  @JsonKey(
    
    name: r'done',
    required: true,
    includeIfNull: false,
  )


  final bool done;



      /// New lessons were found
  @JsonKey(
    
    name: r'lessons',
    required: false,
    includeIfNull: false,
  )


  final bool? lessons;



      /// A code review finished
  @JsonKey(
    
    name: r'review',
    required: false,
    includeIfNull: false,
  )


  final bool? review;



      /// Preview screenshots are ready
  @JsonKey(
    
    name: r'preview',
    required: false,
    includeIfNull: false,
  )


  final bool? preview;



      /// Send phone screenshots to Telegram with the message
  @JsonKey(
    
    name: r'previewPhotos',
    required: false,
    includeIfNull: false,
  )


  final bool? previewPhotos;



      /// Follow-up tickets were suggested
  @JsonKey(
    
    name: r'followUps',
    required: false,
    includeIfNull: false,
  )


  final bool? followUps;



      /// A watched branch went red
  @JsonKey(
    
    name: r'ci',
    required: false,
    includeIfNull: false,
  )


  final bool? ci;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NotifySettings &&
      other.push == push &&
      other.telegram == telegram &&
      other.needsYou == needsYou &&
      other.stopped == stopped &&
      other.done == done &&
      other.lessons == lessons &&
      other.review == review &&
      other.preview == preview &&
      other.previewPhotos == previewPhotos &&
      other.followUps == followUps &&
      other.ci == ci;

    @override
    int get hashCode =>
        push.hashCode +
        telegram.hashCode +
        needsYou.hashCode +
        stopped.hashCode +
        done.hashCode +
        lessons.hashCode +
        review.hashCode +
        preview.hashCode +
        previewPhotos.hashCode +
        followUps.hashCode +
        ci.hashCode;

  factory NotifySettings.fromJson(Map<String, dynamic> json) => _$NotifySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$NotifySettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

