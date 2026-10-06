// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LinkCWProxy {
  Link title(String title);

  Link url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Link(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Link(...).copyWith(id: 12, name: "My name")
  /// ````
  Link call({String title, String url});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLink.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLink.copyWith.fieldName(...)`
class _$LinkCWProxyImpl implements _$LinkCWProxy {
  const _$LinkCWProxyImpl(this._value);

  final Link _value;

  @override
  Link title(String title) => this(title: title);

  @override
  Link url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Link(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Link(...).copyWith(id: 12, name: "My name")
  /// ````
  Link call({
    Object? title = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return Link(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $LinkCopyWith on Link {
  /// Returns a callable class that can be used as follows: `instanceOfLink.copyWith(...)` or like so:`instanceOfLink.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LinkCWProxy get copyWith => _$LinkCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Link _$LinkFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Link', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['title', 'url']);
      final val = Link(
        title: $checkedConvert('title', (v) => v as String),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LinkToJson(Link instance) => <String, dynamic>{
  'title': instance.title,
  'url': instance.url,
};
