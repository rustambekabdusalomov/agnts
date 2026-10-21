//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_benchmark_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunBenchmarkRequest {
  /// Returns a new [RunBenchmarkRequest] instance.
  RunBenchmarkRequest({

     this.models,
  });

      /// Stage (analyze, coding, retry, review) → model, for these replays only
  @JsonKey(
    
    name: r'models',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? models;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RunBenchmarkRequest &&
      other.models == models;

    @override
    int get hashCode =>
        models.hashCode;

  factory RunBenchmarkRequest.fromJson(Map<String, dynamic> json) => _$RunBenchmarkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RunBenchmarkRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

