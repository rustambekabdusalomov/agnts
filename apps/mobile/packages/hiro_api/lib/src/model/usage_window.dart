//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usage_window.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UsageWindow {
  /// Returns a new [UsageWindow] instance.
  UsageWindow({

     this.utilization,

     this.resetsAt,
  });

      /// 0 to 1
  @JsonKey(
    
    name: r'utilization',
    required: false,
    includeIfNull: false,
  )


  final double? utilization;



  @JsonKey(
    
    name: r'resetsAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? resetsAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UsageWindow &&
      other.utilization == utilization &&
      other.resetsAt == resetsAt;

    @override
    int get hashCode =>
        utilization.hashCode +
        resetsAt.hashCode;

  factory UsageWindow.fromJson(Map<String, dynamic> json) => _$UsageWindowFromJson(json);

  Map<String, dynamic> toJson() => _$UsageWindowToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

