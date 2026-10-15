// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_pull_thread_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ResolvePullThreadRequestCWProxy {
  ResolvePullThreadRequest threadId(String threadId);

  ResolvePullThreadRequest resolved(bool resolved);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResolvePullThreadRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResolvePullThreadRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ResolvePullThreadRequest call({String threadId, bool resolved});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfResolvePullThreadRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfResolvePullThreadRequest.copyWith.fieldName(...)`
class _$ResolvePullThreadRequestCWProxyImpl
    implements _$ResolvePullThreadRequestCWProxy {
  const _$ResolvePullThreadRequestCWProxyImpl(this._value);

  final ResolvePullThreadRequest _value;

  @override
  ResolvePullThreadRequest threadId(String threadId) =>
      this(threadId: threadId);

  @override
  ResolvePullThreadRequest resolved(bool resolved) => this(resolved: resolved);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResolvePullThreadRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResolvePullThreadRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ResolvePullThreadRequest call({
    Object? threadId = const $CopyWithPlaceholder(),
    Object? resolved = const $CopyWithPlaceholder(),
  }) {
    return ResolvePullThreadRequest(
      threadId: threadId == const $CopyWithPlaceholder()
          ? _value.threadId
          // ignore: cast_nullable_to_non_nullable
          : threadId as String,
      resolved: resolved == const $CopyWithPlaceholder()
          ? _value.resolved
          // ignore: cast_nullable_to_non_nullable
          : resolved as bool,
    );
  }
}

extension $ResolvePullThreadRequestCopyWith on ResolvePullThreadRequest {
  /// Returns a callable class that can be used as follows: `instanceOfResolvePullThreadRequest.copyWith(...)` or like so:`instanceOfResolvePullThreadRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ResolvePullThreadRequestCWProxy get copyWith =>
      _$ResolvePullThreadRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolvePullThreadRequest _$ResolvePullThreadRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ResolvePullThreadRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['threadId', 'resolved']);
  final val = ResolvePullThreadRequest(
    threadId: $checkedConvert('threadId', (v) => v as String),
    resolved: $checkedConvert('resolved', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$ResolvePullThreadRequestToJson(
  ResolvePullThreadRequest instance,
) => <String, dynamic>{
  'threadId': instance.threadId,
  'resolved': instance.resolved,
};
