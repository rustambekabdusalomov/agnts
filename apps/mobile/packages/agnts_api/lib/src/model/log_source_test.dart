//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/log_fields.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_source_test.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogSourceTest {
  /// Returns a new [LogSourceTest] instance.
  LogSourceTest({

    required  this.version,

    required  this.fields,

    required  this.labels,

    required  this.sample,

     this.newest,

    required  this.network,

    required  this.latencyMs,
  });

  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final String version;



  @JsonKey(
    
    name: r'fields',
    required: true,
    includeIfNull: false,
  )


  final LogFields fields;



  @JsonKey(
    
    name: r'labels',
    required: true,
    includeIfNull: false,
  )


  final List<String> labels;



      /// The newest entry, redacted
  @JsonKey(
    
    name: r'sample',
    required: true,
    includeIfNull: false,
  )


  final String sample;



  @JsonKey(
    
    name: r'newest',
    required: false,
    includeIfNull: false,
  )


  final DateTime? newest;



      /// The private network used, or empty for a direct connection
  @JsonKey(
    
    name: r'network',
    required: true,
    includeIfNull: false,
  )


  final String network;



  @JsonKey(
    
    name: r'latencyMs',
    required: true,
    includeIfNull: false,
  )


  final int latencyMs;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogSourceTest &&
      other.version == version &&
      other.fields == fields &&
      other.labels == labels &&
      other.sample == sample &&
      other.newest == newest &&
      other.network == network &&
      other.latencyMs == latencyMs;

    @override
    int get hashCode =>
        version.hashCode +
        fields.hashCode +
        labels.hashCode +
        sample.hashCode +
        newest.hashCode +
        network.hashCode +
        latencyMs.hashCode;

  factory LogSourceTest.fromJson(Map<String, dynamic> json) => _$LogSourceTestFromJson(json);

  Map<String, dynamic> toJson() => _$LogSourceTestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

