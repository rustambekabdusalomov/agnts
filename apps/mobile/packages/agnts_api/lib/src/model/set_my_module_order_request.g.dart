// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_my_module_order_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetMyModuleOrderRequestCWProxy {
  SetMyModuleOrderRequest order(List<Module>? order);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetMyModuleOrderRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetMyModuleOrderRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetMyModuleOrderRequest call({List<Module>? order});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetMyModuleOrderRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetMyModuleOrderRequest.copyWith.fieldName(...)`
class _$SetMyModuleOrderRequestCWProxyImpl
    implements _$SetMyModuleOrderRequestCWProxy {
  const _$SetMyModuleOrderRequestCWProxyImpl(this._value);

  final SetMyModuleOrderRequest _value;

  @override
  SetMyModuleOrderRequest order(List<Module>? order) => this(order: order);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetMyModuleOrderRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetMyModuleOrderRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SetMyModuleOrderRequest call({Object? order = const $CopyWithPlaceholder()}) {
    return SetMyModuleOrderRequest(
      order: order == const $CopyWithPlaceholder()
          ? _value.order
          // ignore: cast_nullable_to_non_nullable
          : order as List<Module>?,
    );
  }
}

extension $SetMyModuleOrderRequestCopyWith on SetMyModuleOrderRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSetMyModuleOrderRequest.copyWith(...)` or like so:`instanceOfSetMyModuleOrderRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetMyModuleOrderRequestCWProxy get copyWith =>
      _$SetMyModuleOrderRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetMyModuleOrderRequest _$SetMyModuleOrderRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SetMyModuleOrderRequest', json, ($checkedConvert) {
  final val = SetMyModuleOrderRequest(
    order: $checkedConvert(
      'order',
      (v) => (v as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ModuleEnumMap, e))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$SetMyModuleOrderRequestToJson(
  SetMyModuleOrderRequest instance,
) => <String, dynamic>{
  'order': ?instance.order?.map((e) => _$ModuleEnumMap[e]!).toList(),
};

const _$ModuleEnumMap = {
  Module.muse: 'muse',
  Module.claude: 'claude',
  Module.codex: 'codex',
};
