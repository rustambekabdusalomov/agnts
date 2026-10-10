//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reviewer_profile_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewerProfileInput {
  /// Returns a new [ReviewerProfileInput] instance.
  ReviewerProfileInput({

    required  this.profile,
  });

      /// Markdown; empty clears it
  @JsonKey(
    
    name: r'profile',
    required: true,
    includeIfNull: false,
  )


  final String profile;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewerProfileInput &&
      other.profile == profile;

    @override
    int get hashCode =>
        profile.hashCode;

  factory ReviewerProfileInput.fromJson(Map<String, dynamic> json) => _$ReviewerProfileInputFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewerProfileInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

