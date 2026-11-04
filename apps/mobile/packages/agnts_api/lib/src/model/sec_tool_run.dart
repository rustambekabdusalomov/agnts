//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sec_tool_run.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecToolRun {
  /// Returns a new [SecToolRun] instance.
  SecToolRun({

    required  this.tool,

    required  this.status,

    required  this.seconds,

    required  this.hits,

     this.error,
  });

      /// opengrep, gitleaks, osv or trivy
  @JsonKey(
    
    name: r'tool',
    required: true,
    includeIfNull: false,
  )


  final String tool;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final SecToolRunStatusEnum status;



  @JsonKey(
    
    name: r'seconds',
    required: true,
    includeIfNull: false,
  )


  final int seconds;



  @JsonKey(
    
    name: r'hits',
    required: true,
    includeIfNull: false,
  )


  final int hits;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecToolRun &&
      other.tool == tool &&
      other.status == status &&
      other.seconds == seconds &&
      other.hits == hits &&
      other.error == error;

    @override
    int get hashCode =>
        tool.hashCode +
        status.hashCode +
        seconds.hashCode +
        hits.hashCode +
        error.hashCode;

  factory SecToolRun.fromJson(Map<String, dynamic> json) => _$SecToolRunFromJson(json);

  Map<String, dynamic> toJson() => _$SecToolRunToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum SecToolRunStatusEnum {
@JsonValue(r'ok')
ok(r'ok'),
@JsonValue(r'failed')
failed(r'failed'),
@JsonValue(r'timeout')
timeout(r'timeout'),
@JsonValue(r'skipped')
skipped(r'skipped');

const SecToolRunStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


