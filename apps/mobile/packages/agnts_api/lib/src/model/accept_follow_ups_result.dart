//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/accept_follow_up_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accept_follow_ups_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AcceptFollowUpsResult {
  /// Returns a new [AcceptFollowUpsResult] instance.
  AcceptFollowUpsResult({

    required  this.results,
  });

  @JsonKey(
    
    name: r'results',
    required: true,
    includeIfNull: false,
  )


  final List<AcceptFollowUpResult> results;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AcceptFollowUpsResult &&
      other.results == results;

    @override
    int get hashCode =>
        results.hashCode;

  factory AcceptFollowUpsResult.fromJson(Map<String, dynamic> json) => _$AcceptFollowUpsResultFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptFollowUpsResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

