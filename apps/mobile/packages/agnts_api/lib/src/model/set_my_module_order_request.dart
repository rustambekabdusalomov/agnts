//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/module.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_my_module_order_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetMyModuleOrderRequest {
  /// Returns a new [SetMyModuleOrderRequest] instance.
  SetMyModuleOrderRequest({

     this.order,
  });

  @JsonKey(
    
    name: r'order',
    required: false,
    includeIfNull: false,
  )


  final List<Module>? order;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetMyModuleOrderRequest &&
      other.order == order;

    @override
    int get hashCode =>
        (order == null ? 0 : order.hashCode);

  factory SetMyModuleOrderRequest.fromJson(Map<String, dynamic> json) => _$SetMyModuleOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetMyModuleOrderRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

