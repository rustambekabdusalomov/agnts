//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'benchmark_run.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BenchmarkRun {
  /// Returns a new [BenchmarkRun] instance.
  BenchmarkRun({

    required  this.original,

     this.replay,

     this.error,
  });

  @JsonKey(
    
    name: r'original',
    required: true,
    includeIfNull: false,
  )


  final String original;



      /// The replay ticket's key
  @JsonKey(
    
    name: r'replay',
    required: false,
    includeIfNull: false,
  )


  final String? replay;



      /// Why the ticket could not be replayed
  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BenchmarkRun &&
      other.original == original &&
      other.replay == replay &&
      other.error == error;

    @override
    int get hashCode =>
        original.hashCode +
        replay.hashCode +
        error.hashCode;

  factory BenchmarkRun.fromJson(Map<String, dynamic> json) => _$BenchmarkRunFromJson(json);

  Map<String, dynamic> toJson() => _$BenchmarkRunToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

