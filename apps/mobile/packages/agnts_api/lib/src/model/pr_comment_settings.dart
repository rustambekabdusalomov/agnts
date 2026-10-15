//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pr_comment_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PRCommentSettings {
  /// Returns a new [PRCommentSettings] instance.
  PRCommentSettings({

    required  this.attribution,

    required  this.learnFromComments,

    required  this.resolveFixed,

    required  this.autoAddress,
  });

      /// Add \"via agnts · <person>\" to comments written through agnts (they all go out as the git host token's user)
  @JsonKey(
    
    name: r'attribution',
    required: true,
    includeIfNull: false,
  )


  final bool attribution;



      /// Keep the comments you write on others' pull requests on the git host as notes on how you review
  @JsonKey(
    
    name: r'learnFromComments',
    required: true,
    includeIfNull: false,
  )


  final bool learnFromComments;



      /// Resolve a reviewer's thread once agnts pushed the fix and answered it
  @JsonKey(
    
    name: r'resolveFixed',
    required: true,
    includeIfNull: false,
  )


  final bool resolveFixed;



      /// Send the unresolved threads back to the ticket when a reviewer requests changes on agnts's pull request (the fix still waits for your approval)
  @JsonKey(
    
    name: r'autoAddress',
    required: true,
    includeIfNull: false,
  )


  final bool autoAddress;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PRCommentSettings &&
      other.attribution == attribution &&
      other.learnFromComments == learnFromComments &&
      other.resolveFixed == resolveFixed &&
      other.autoAddress == autoAddress;

    @override
    int get hashCode =>
        attribution.hashCode +
        learnFromComments.hashCode +
        resolveFixed.hashCode +
        autoAddress.hashCode;

  factory PRCommentSettings.fromJson(Map<String, dynamic> json) => _$PRCommentSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$PRCommentSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

