// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_shot.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreviewShotCWProxy {
  PreviewShot id(String id);

  PreviewShot name(String name);

  PreviewShot route(String route);

  PreviewShot viewport(PreviewShotViewportEnum viewport);

  PreviewShot side(PreviewShotSideEnum side);

  PreviewShot note(String? note);

  PreviewShot width(int? width);

  PreviewShot height(int? height);

  PreviewShot consoleErrors(int? consoleErrors);

  PreviewShot url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreviewShot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreviewShot(...).copyWith(id: 12, name: "My name")
  /// ````
  PreviewShot call({
    String id,
    String name,
    String route,
    PreviewShotViewportEnum viewport,
    PreviewShotSideEnum side,
    String? note,
    int? width,
    int? height,
    int? consoleErrors,
    String url,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreviewShot.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreviewShot.copyWith.fieldName(...)`
class _$PreviewShotCWProxyImpl implements _$PreviewShotCWProxy {
  const _$PreviewShotCWProxyImpl(this._value);

  final PreviewShot _value;

  @override
  PreviewShot id(String id) => this(id: id);

  @override
  PreviewShot name(String name) => this(name: name);

  @override
  PreviewShot route(String route) => this(route: route);

  @override
  PreviewShot viewport(PreviewShotViewportEnum viewport) =>
      this(viewport: viewport);

  @override
  PreviewShot side(PreviewShotSideEnum side) => this(side: side);

  @override
  PreviewShot note(String? note) => this(note: note);

  @override
  PreviewShot width(int? width) => this(width: width);

  @override
  PreviewShot height(int? height) => this(height: height);

  @override
  PreviewShot consoleErrors(int? consoleErrors) =>
      this(consoleErrors: consoleErrors);

  @override
  PreviewShot url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreviewShot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreviewShot(...).copyWith(id: 12, name: "My name")
  /// ````
  PreviewShot call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? route = const $CopyWithPlaceholder(),
    Object? viewport = const $CopyWithPlaceholder(),
    Object? side = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? consoleErrors = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return PreviewShot(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      route: route == const $CopyWithPlaceholder()
          ? _value.route
          // ignore: cast_nullable_to_non_nullable
          : route as String,
      viewport: viewport == const $CopyWithPlaceholder()
          ? _value.viewport
          // ignore: cast_nullable_to_non_nullable
          : viewport as PreviewShotViewportEnum,
      side: side == const $CopyWithPlaceholder()
          ? _value.side
          // ignore: cast_nullable_to_non_nullable
          : side as PreviewShotSideEnum,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      width: width == const $CopyWithPlaceholder()
          ? _value.width
          // ignore: cast_nullable_to_non_nullable
          : width as int?,
      height: height == const $CopyWithPlaceholder()
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as int?,
      consoleErrors: consoleErrors == const $CopyWithPlaceholder()
          ? _value.consoleErrors
          // ignore: cast_nullable_to_non_nullable
          : consoleErrors as int?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $PreviewShotCopyWith on PreviewShot {
  /// Returns a callable class that can be used as follows: `instanceOfPreviewShot.copyWith(...)` or like so:`instanceOfPreviewShot.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreviewShotCWProxy get copyWith => _$PreviewShotCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreviewShot _$PreviewShotFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PreviewShot', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'name', 'route', 'viewport', 'side', 'url'],
      );
      final val = PreviewShot(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        route: $checkedConvert('route', (v) => v as String),
        viewport: $checkedConvert(
          'viewport',
          (v) => $enumDecode(_$PreviewShotViewportEnumEnumMap, v),
        ),
        side: $checkedConvert(
          'side',
          (v) => $enumDecode(_$PreviewShotSideEnumEnumMap, v),
        ),
        note: $checkedConvert('note', (v) => v as String?),
        width: $checkedConvert('width', (v) => (v as num?)?.toInt()),
        height: $checkedConvert('height', (v) => (v as num?)?.toInt()),
        consoleErrors: $checkedConvert(
          'consoleErrors',
          (v) => (v as num?)?.toInt(),
        ),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$PreviewShotToJson(PreviewShot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'route': instance.route,
      'viewport': _$PreviewShotViewportEnumEnumMap[instance.viewport]!,
      'side': _$PreviewShotSideEnumEnumMap[instance.side]!,
      'note': ?instance.note,
      'width': ?instance.width,
      'height': ?instance.height,
      'consoleErrors': ?instance.consoleErrors,
      'url': instance.url,
    };

const _$PreviewShotViewportEnumEnumMap = {
  PreviewShotViewportEnum.desktop: 'desktop',
  PreviewShotViewportEnum.phone: 'phone',
};

const _$PreviewShotSideEnumEnumMap = {
  PreviewShotSideEnum.after: 'after',
  PreviewShotSideEnum.before: 'before',
};
