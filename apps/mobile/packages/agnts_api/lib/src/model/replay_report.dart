//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/replay_result.dart';
import 'package:agnts_api/src/model/replay_version.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'replay_report.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReplayReport {
  /// Returns a new [ReplayReport] instance.
  ReplayReport({

    required  this.versions,

    required  this.replays,
  });

      /// Replays with a change, summed by the prompt version they ran with
  @JsonKey(
    
    name: r'versions',
    required: true,
    includeIfNull: false,
  )


  final List<ReplayVersion> versions;



      /// The newest replays first
  @JsonKey(
    
    name: r'replays',
    required: true,
    includeIfNull: false,
  )


  final List<ReplayResult> replays;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReplayReport &&
      other.versions == versions &&
      other.replays == replays;

    @override
    int get hashCode =>
        versions.hashCode +
        replays.hashCode;

  factory ReplayReport.fromJson(Map<String, dynamic> json) => _$ReplayReportFromJson(json);

  Map<String, dynamic> toJson() => _$ReplayReportToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

