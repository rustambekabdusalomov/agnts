// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FeedbackCWProxy {
  Feedback id(int id);

  Feedback title(String title);

  Feedback description(String description);

  Feedback status(FeedbackStatusEnum status);

  Feedback sender(String sender);

  Feedback email(String? email);

  Feedback userId(int? userId);

  Feedback workspace(String? workspace);

  Feedback createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Feedback(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Feedback(...).copyWith(id: 12, name: "My name")
  /// ````
  Feedback call({
    int id,
    String title,
    String description,
    FeedbackStatusEnum status,
    String sender,
    String? email,
    int? userId,
    String? workspace,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFeedback.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFeedback.copyWith.fieldName(...)`
class _$FeedbackCWProxyImpl implements _$FeedbackCWProxy {
  const _$FeedbackCWProxyImpl(this._value);

  final Feedback _value;

  @override
  Feedback id(int id) => this(id: id);

  @override
  Feedback title(String title) => this(title: title);

  @override
  Feedback description(String description) => this(description: description);

  @override
  Feedback status(FeedbackStatusEnum status) => this(status: status);

  @override
  Feedback sender(String sender) => this(sender: sender);

  @override
  Feedback email(String? email) => this(email: email);

  @override
  Feedback userId(int? userId) => this(userId: userId);

  @override
  Feedback workspace(String? workspace) => this(workspace: workspace);

  @override
  Feedback createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Feedback(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Feedback(...).copyWith(id: 12, name: "My name")
  /// ````
  Feedback call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? sender = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? userId = const $CopyWithPlaceholder(),
    Object? workspace = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return Feedback(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as FeedbackStatusEnum,
      sender: sender == const $CopyWithPlaceholder()
          ? _value.sender
          // ignore: cast_nullable_to_non_nullable
          : sender as String,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int?,
      workspace: workspace == const $CopyWithPlaceholder()
          ? _value.workspace
          // ignore: cast_nullable_to_non_nullable
          : workspace as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $FeedbackCopyWith on Feedback {
  /// Returns a callable class that can be used as follows: `instanceOfFeedback.copyWith(...)` or like so:`instanceOfFeedback.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FeedbackCWProxy get copyWith => _$FeedbackCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feedback _$FeedbackFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Feedback', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'title',
          'description',
          'status',
          'sender',
          'createdAt',
        ],
      );
      final val = Feedback(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        title: $checkedConvert('title', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$FeedbackStatusEnumEnumMap, v),
        ),
        sender: $checkedConvert('sender', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String?),
        userId: $checkedConvert('userId', (v) => (v as num?)?.toInt()),
        workspace: $checkedConvert('workspace', (v) => v as String?),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$FeedbackToJson(Feedback instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'status': _$FeedbackStatusEnumEnumMap[instance.status]!,
  'sender': instance.sender,
  'email': ?instance.email,
  'userId': ?instance.userId,
  'workspace': ?instance.workspace,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$FeedbackStatusEnumEnumMap = {
  FeedbackStatusEnum.new_: 'new',
  FeedbackStatusEnum.done: 'done',
};
