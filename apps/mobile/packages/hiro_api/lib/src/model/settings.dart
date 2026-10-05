//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/git_settings.dart';
import 'package:hiro_api/src/model/notify_settings.dart';
import 'package:hiro_api/src/model/stage_models.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Settings {
  /// Returns a new [Settings] instance.
  Settings({

    required  this.models,

    required  this.maxTurns,

    required  this.timeoutMin,

    required  this.allow,

    required  this.deny,

    required  this.askFirst,

    required  this.autoResume,

     this.autoLearn,

     this.autoReview,

    required  this.pauseAbove,

    required  this.parallel,

    required  this.git,

     this.notify,
  });

  @JsonKey(
    
    name: r'models',
    required: true,
    includeIfNull: false,
  )


  final StageModels models;



          // minimum: 20
          // maximum: 200
  @JsonKey(
    
    name: r'maxTurns',
    required: true,
    includeIfNull: false,
  )


  final int maxTurns;



          // minimum: 10
          // maximum: 120
  @JsonKey(
    
    name: r'timeoutMin',
    required: true,
    includeIfNull: false,
  )


  final int timeoutMin;



  @JsonKey(
    
    name: r'allow',
    required: true,
    includeIfNull: false,
  )


  final List<String> allow;



  @JsonKey(
    
    name: r'deny',
    required: true,
    includeIfNull: false,
  )


  final List<String> deny;



  @JsonKey(
    
    name: r'askFirst',
    required: true,
    includeIfNull: false,
  )


  final bool askFirst;



  @JsonKey(
    
    name: r'autoResume',
    required: true,
    includeIfNull: false,
  )


  final bool autoResume;



      /// Learn from every pushed ticket
  @JsonKey(
    
    name: r'autoLearn',
    required: false,
    includeIfNull: false,
  )


  final bool? autoLearn;



      /// Review every result while it waits for review
  @JsonKey(
    
    name: r'autoReview',
    required: false,
    includeIfNull: false,
  )


  final bool? autoReview;



          // minimum: 50
          // maximum: 100
  @JsonKey(
    
    name: r'pauseAbove',
    required: true,
    includeIfNull: false,
  )


  final int pauseAbove;



          // minimum: 1
          // maximum: 3
  @JsonKey(
    
    name: r'parallel',
    required: true,
    includeIfNull: false,
  )


  final int parallel;



  @JsonKey(
    
    name: r'git',
    required: true,
    includeIfNull: false,
  )


  final GitSettings git;



  @JsonKey(
    
    name: r'notify',
    required: false,
    includeIfNull: false,
  )


  final NotifySettings? notify;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Settings &&
      other.models == models &&
      other.maxTurns == maxTurns &&
      other.timeoutMin == timeoutMin &&
      other.allow == allow &&
      other.deny == deny &&
      other.askFirst == askFirst &&
      other.autoResume == autoResume &&
      other.autoLearn == autoLearn &&
      other.autoReview == autoReview &&
      other.pauseAbove == pauseAbove &&
      other.parallel == parallel &&
      other.git == git &&
      other.notify == notify;

    @override
    int get hashCode =>
        models.hashCode +
        maxTurns.hashCode +
        timeoutMin.hashCode +
        allow.hashCode +
        deny.hashCode +
        askFirst.hashCode +
        autoResume.hashCode +
        autoLearn.hashCode +
        autoReview.hashCode +
        pauseAbove.hashCode +
        parallel.hashCode +
        git.hashCode +
        notify.hashCode;

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

