// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_ticket_document_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateTicketDocumentRequestCWProxy {
  CreateTicketDocumentRequest instruction(String? instruction);

  CreateTicketDocumentRequest language(
    CreateTicketDocumentRequestLanguageEnum? language,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateTicketDocumentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateTicketDocumentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateTicketDocumentRequest call({
    String? instruction,
    CreateTicketDocumentRequestLanguageEnum? language,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateTicketDocumentRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateTicketDocumentRequest.copyWith.fieldName(...)`
class _$CreateTicketDocumentRequestCWProxyImpl
    implements _$CreateTicketDocumentRequestCWProxy {
  const _$CreateTicketDocumentRequestCWProxyImpl(this._value);

  final CreateTicketDocumentRequest _value;

  @override
  CreateTicketDocumentRequest instruction(String? instruction) =>
      this(instruction: instruction);

  @override
  CreateTicketDocumentRequest language(
    CreateTicketDocumentRequestLanguageEnum? language,
  ) => this(language: language);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateTicketDocumentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateTicketDocumentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateTicketDocumentRequest call({
    Object? instruction = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
  }) {
    return CreateTicketDocumentRequest(
      instruction: instruction == const $CopyWithPlaceholder()
          ? _value.instruction
          // ignore: cast_nullable_to_non_nullable
          : instruction as String?,
      language: language == const $CopyWithPlaceholder()
          ? _value.language
          // ignore: cast_nullable_to_non_nullable
          : language as CreateTicketDocumentRequestLanguageEnum?,
    );
  }
}

extension $CreateTicketDocumentRequestCopyWith on CreateTicketDocumentRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateTicketDocumentRequest.copyWith(...)` or like so:`instanceOfCreateTicketDocumentRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateTicketDocumentRequestCWProxy get copyWith =>
      _$CreateTicketDocumentRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTicketDocumentRequest _$CreateTicketDocumentRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateTicketDocumentRequest', json, ($checkedConvert) {
  final val = CreateTicketDocumentRequest(
    instruction: $checkedConvert('instruction', (v) => v as String?),
    language: $checkedConvert(
      'language',
      (v) => $enumDecodeNullable(
        _$CreateTicketDocumentRequestLanguageEnumEnumMap,
        v,
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$CreateTicketDocumentRequestToJson(
  CreateTicketDocumentRequest instance,
) => <String, dynamic>{
  'instruction': ?instance.instruction,
  'language':
      ?_$CreateTicketDocumentRequestLanguageEnumEnumMap[instance.language],
};

const _$CreateTicketDocumentRequestLanguageEnumEnumMap = {
  CreateTicketDocumentRequestLanguageEnum.en: 'en',
  CreateTicketDocumentRequestLanguageEnum.ru: 'ru',
  CreateTicketDocumentRequestLanguageEnum.uz: 'uz',
};
