//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/egress_upstream.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'egress_status.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EgressStatus {
  /// Returns a new [EgressStatus] instance.
  EgressStatus({

    required  this.reachable,

     this.error,

     this.upstream,
  });

      /// agnts could read the egress proxy's status
  @JsonKey(
    
    name: r'reachable',
    required: true,
    includeIfNull: false,
  )


  final bool reachable;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



  @JsonKey(
    
    name: r'upstream',
    required: false,
    includeIfNull: false,
  )


  final EgressUpstream? upstream;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EgressStatus &&
      other.reachable == reachable &&
      other.error == error &&
      other.upstream == upstream;

    @override
    int get hashCode =>
        reachable.hashCode +
        error.hashCode +
        upstream.hashCode;

  factory EgressStatus.fromJson(Map<String, dynamic> json) => _$EgressStatusFromJson(json);

  Map<String, dynamic> toJson() => _$EgressStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

