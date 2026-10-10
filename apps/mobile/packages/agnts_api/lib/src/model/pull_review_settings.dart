//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pull_review_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullReviewSettings {
  /// Returns a new [PullReviewSettings] instance.
  PullReviewSettings({

    required  this.enabled,

    required  this.reviewRequested,

    required  this.skipDrafts,

    required  this.rereview,

    required  this.mergeMethod,
  });

      /// Sync the pull requests waiting for you every few minutes and review the new ones
  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;



      /// Also take pull requests whose review is requested from you, not only those assigned to you
  @JsonKey(
    
    name: r'reviewRequested',
    required: true,
    includeIfNull: false,
  )


  final bool reviewRequested;



      /// Leave draft pull requests alone until they are ready
  @JsonKey(
    
    name: r'skipDrafts',
    required: true,
    includeIfNull: false,
  )


  final bool skipDrafts;



      /// Review again when the author pushes new commits while agnts's review waits for you
  @JsonKey(
    
    name: r'rereview',
    required: true,
    includeIfNull: false,
  )


  final bool rereview;



      /// How an accepted pull request is merged
  @JsonKey(
    
    name: r'mergeMethod',
    required: true,
    includeIfNull: false,
  )


  final PullReviewSettingsMergeMethodEnum mergeMethod;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullReviewSettings &&
      other.enabled == enabled &&
      other.reviewRequested == reviewRequested &&
      other.skipDrafts == skipDrafts &&
      other.rereview == rereview &&
      other.mergeMethod == mergeMethod;

    @override
    int get hashCode =>
        enabled.hashCode +
        reviewRequested.hashCode +
        skipDrafts.hashCode +
        rereview.hashCode +
        mergeMethod.hashCode;

  factory PullReviewSettings.fromJson(Map<String, dynamic> json) => _$PullReviewSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$PullReviewSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// How an accepted pull request is merged
enum PullReviewSettingsMergeMethodEnum {
@JsonValue(r'merge')
merge(r'merge'),
@JsonValue(r'squash')
squash(r'squash'),
@JsonValue(r'rebase')
rebase(r'rebase');

const PullReviewSettingsMergeMethodEnum(this.value);

final String value;

@override
String toString() => value;
}


