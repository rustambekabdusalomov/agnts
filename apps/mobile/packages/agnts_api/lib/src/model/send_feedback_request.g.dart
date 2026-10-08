// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_feedback_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SendFeedbackRequestCWProxy {
  SendFeedbackRequest title(String title);

  SendFeedbackRequest description(String description);

  SendFeedbackRequest workspace(String? workspace);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendFeedbackRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendFeedbackRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendFeedbackRequest call({
    String title,
    String description,
    String? workspace,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSendFeedbackRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSendFeedbackRequest.copyWith.fieldName(...)`
class _$SendFeedbackRequestCWProxyImpl implements _$SendFeedbackRequestCWProxy {
  const _$SendFeedbackRequestCWProxyImpl(this._value);

  final SendFeedbackRequest _value;

  @override
  SendFeedbackRequest title(String title) => this(title: title);

  @override
  SendFeedbackRequest description(String description) =>
      this(description: description);

  @override
  SendFeedbackRequest workspace(String? workspace) =>
      this(workspace: workspace);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendFeedbackRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendFeedbackRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendFeedbackRequest call({
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? workspace = const $CopyWithPlaceholder(),
  }) {
    return SendFeedbackRequest(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      workspace: workspace == const $CopyWithPlaceholder()
          ? _value.workspace
          // ignore: cast_nullable_to_non_nullable
          : workspace as String?,
    );
  }
}

extension $SendFeedbackRequestCopyWith on SendFeedbackRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSendFeedbackRequest.copyWith(...)` or like so:`instanceOfSendFeedbackRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SendFeedbackRequestCWProxy get copyWith =>
      _$SendFeedbackRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendFeedbackRequest _$SendFeedbackRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SendFeedbackRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['title', 'description']);
      final val = SendFeedbackRequest(
        title: $checkedConvert('title', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        workspace: $checkedConvert('workspace', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SendFeedbackRequestToJson(
  SendFeedbackRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'workspace': ?instance.workspace,
};
