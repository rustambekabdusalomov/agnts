//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/egress_upstream_exit.dart';
import 'package:agnts_api/src/model/egress_upstream_history_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'egress_upstream.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EgressUpstream {
  /// Returns a new [EgressUpstream] instance.
  EgressUpstream({

    required  this.configured,

     this.via,

     this.hosts,

     this.target,

    required  this.ok,

     this.checkedAt,

     this.lastOkAt,

     this.downSince,

    required  this.latencyMs,

     this.error,

     this.exit,

    required  this.history,

    required  this.calls,

    required  this.failed,

     this.lastCallError,
  });

      /// AGNTS_EGRESS_UPSTREAM is set
  @JsonKey(
    
    name: r'configured',
    required: true,
    includeIfNull: false,
  )


  final bool configured;



      /// The upstream proxy
  @JsonKey(
    
    name: r'via',
    required: false,
    includeIfNull: false,
  )


  final String? via;



  @JsonKey(
    
    name: r'hosts',
    required: false,
    includeIfNull: false,
  )


  final List<String>? hosts;



      /// The host each check reaches through it
  @JsonKey(
    
    name: r'target',
    required: false,
    includeIfNull: false,
  )


  final String? target;



  @JsonKey(
    
    name: r'ok',
    required: true,
    includeIfNull: false,
  )


  final bool ok;



  @JsonKey(
    
    name: r'checkedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? checkedAt;



  @JsonKey(
    
    name: r'lastOkAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastOkAt;



  @JsonKey(
    
    name: r'downSince',
    required: false,
    includeIfNull: false,
  )


  final DateTime? downSince;



  @JsonKey(
    
    name: r'latencyMs',
    required: true,
    includeIfNull: false,
  )


  final int latencyMs;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



  @JsonKey(
    
    name: r'exit',
    required: false,
    includeIfNull: false,
  )


  final EgressUpstreamExit? exit;



  @JsonKey(
    
    name: r'history',
    required: true,
    includeIfNull: false,
  )


  final List<EgressUpstreamHistoryInner> history;



      /// Connections runs made through it since egress started
  @JsonKey(
    
    name: r'calls',
    required: true,
    includeIfNull: false,
  )


  final int calls;



  @JsonKey(
    
    name: r'failed',
    required: true,
    includeIfNull: false,
  )


  final int failed;



  @JsonKey(
    
    name: r'lastCallError',
    required: false,
    includeIfNull: false,
  )


  final String? lastCallError;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EgressUpstream &&
      other.configured == configured &&
      other.via == via &&
      other.hosts == hosts &&
      other.target == target &&
      other.ok == ok &&
      other.checkedAt == checkedAt &&
      other.lastOkAt == lastOkAt &&
      other.downSince == downSince &&
      other.latencyMs == latencyMs &&
      other.error == error &&
      other.exit == exit &&
      other.history == history &&
      other.calls == calls &&
      other.failed == failed &&
      other.lastCallError == lastCallError;

    @override
    int get hashCode =>
        configured.hashCode +
        via.hashCode +
        hosts.hashCode +
        target.hashCode +
        ok.hashCode +
        checkedAt.hashCode +
        lastOkAt.hashCode +
        downSince.hashCode +
        latencyMs.hashCode +
        error.hashCode +
        exit.hashCode +
        history.hashCode +
        calls.hashCode +
        failed.hashCode +
        lastCallError.hashCode;

  factory EgressUpstream.fromJson(Map<String, dynamic> json) => _$EgressUpstreamFromJson(json);

  Map<String, dynamic> toJson() => _$EgressUpstreamToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

