// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AttachmentCWProxy {
  Attachment id(int id);

  Attachment name(String name);

  Attachment contentType(String contentType);

  Attachment size(int size);

  Attachment purpose(AttachmentPurposeEnum purpose);

  Attachment questionId(int? questionId);

  Attachment image(bool? image);

  Attachment url(String url);

  Attachment createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Attachment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Attachment(...).copyWith(id: 12, name: "My name")
  /// ````
  Attachment call({
    int id,
    String name,
    String contentType,
    int size,
    AttachmentPurposeEnum purpose,
    int? questionId,
    bool? image,
    String url,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAttachment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAttachment.copyWith.fieldName(...)`
class _$AttachmentCWProxyImpl implements _$AttachmentCWProxy {
  const _$AttachmentCWProxyImpl(this._value);

  final Attachment _value;

  @override
  Attachment id(int id) => this(id: id);

  @override
  Attachment name(String name) => this(name: name);

  @override
  Attachment contentType(String contentType) => this(contentType: contentType);

  @override
  Attachment size(int size) => this(size: size);

  @override
  Attachment purpose(AttachmentPurposeEnum purpose) => this(purpose: purpose);

  @override
  Attachment questionId(int? questionId) => this(questionId: questionId);

  @override
  Attachment image(bool? image) => this(image: image);

  @override
  Attachment url(String url) => this(url: url);

  @override
  Attachment createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Attachment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Attachment(...).copyWith(id: 12, name: "My name")
  /// ````
  Attachment call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? contentType = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
    Object? questionId = const $CopyWithPlaceholder(),
    Object? image = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return Attachment(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      contentType: contentType == const $CopyWithPlaceholder()
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as String,
      size: size == const $CopyWithPlaceholder()
          ? _value.size
          // ignore: cast_nullable_to_non_nullable
          : size as int,
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as AttachmentPurposeEnum,
      questionId: questionId == const $CopyWithPlaceholder()
          ? _value.questionId
          // ignore: cast_nullable_to_non_nullable
          : questionId as int?,
      image: image == const $CopyWithPlaceholder()
          ? _value.image
          // ignore: cast_nullable_to_non_nullable
          : image as bool?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $AttachmentCopyWith on Attachment {
  /// Returns a callable class that can be used as follows: `instanceOfAttachment.copyWith(...)` or like so:`instanceOfAttachment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AttachmentCWProxy get copyWith => _$AttachmentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Attachment', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'name',
          'contentType',
          'size',
          'purpose',
          'url',
          'createdAt',
        ],
      );
      final val = Attachment(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        contentType: $checkedConvert('contentType', (v) => v as String),
        size: $checkedConvert('size', (v) => (v as num).toInt()),
        purpose: $checkedConvert(
          'purpose',
          (v) => $enumDecode(_$AttachmentPurposeEnumEnumMap, v),
        ),
        questionId: $checkedConvert('questionId', (v) => (v as num?)?.toInt()),
        image: $checkedConvert('image', (v) => v as bool?),
        url: $checkedConvert('url', (v) => v as String),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contentType': instance.contentType,
      'size': instance.size,
      'purpose': _$AttachmentPurposeEnumEnumMap[instance.purpose]!,
      'questionId': ?instance.questionId,
      'image': ?instance.image,
      'url': instance.url,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AttachmentPurposeEnumEnumMap = {
  AttachmentPurposeEnum.pending: 'pending',
  AttachmentPurposeEnum.ticket: 'ticket',
  AttachmentPurposeEnum.answer: 'answer',
  AttachmentPurposeEnum.retry: 'retry',
  AttachmentPurposeEnum.feedback: 'feedback',
  AttachmentPurposeEnum.chat: 'chat',
  AttachmentPurposeEnum.assistant: 'assistant',
};
