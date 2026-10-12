//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/network_activity_dials_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_activity.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NetworkActivity {
  /// Returns a new [NetworkActivity] instance.
  NetworkActivity({

    required  this.today,

    required  this.refused,

    required  this.dials,
  });

      /// Connections in the last 24 hours
  @JsonKey(
    
    name: r'today',
    required: true,
    includeIfNull: false,
  )


  final int today;



      /// Of those, refused or failed
  @JsonKey(
    
    name: r'refused',
    required: true,
    includeIfNull: false,
  )


  final int refused;



  @JsonKey(
    
    name: r'dials',
    required: true,
    includeIfNull: false,
  )


  final List<NetworkActivityDialsInner> dials;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NetworkActivity &&
      other.today == today &&
      other.refused == refused &&
      other.dials == dials;

    @override
    int get hashCode =>
        today.hashCode +
        refused.hashCode +
        dials.hashCode;

  factory NetworkActivity.fromJson(Map<String, dynamic> json) => _$NetworkActivityFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkActivityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

