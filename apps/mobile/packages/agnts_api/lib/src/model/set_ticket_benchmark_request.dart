//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_ticket_benchmark_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetTicketBenchmarkRequest {
  /// Returns a new [SetTicketBenchmarkRequest] instance.
  SetTicketBenchmarkRequest({

    required  this.benchmark,
  });

  @JsonKey(
    
    name: r'benchmark',
    required: true,
    includeIfNull: false,
  )


  final bool benchmark;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetTicketBenchmarkRequest &&
      other.benchmark == benchmark;

    @override
    int get hashCode =>
        benchmark.hashCode;

  factory SetTicketBenchmarkRequest.fromJson(Map<String, dynamic> json) => _$SetTicketBenchmarkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetTicketBenchmarkRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

