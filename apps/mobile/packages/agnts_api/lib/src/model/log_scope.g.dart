// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_scope.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogScopeCWProxy {
  LogScope selector(String? selector);

  LogScope index(String? index);

  LogScope streams(List<String>? streams);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogScope(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogScope(...).copyWith(id: 12, name: "My name")
  /// ````
  LogScope call({String? selector, String? index, List<String>? streams});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogScope.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogScope.copyWith.fieldName(...)`
class _$LogScopeCWProxyImpl implements _$LogScopeCWProxy {
  const _$LogScopeCWProxyImpl(this._value);

  final LogScope _value;

  @override
  LogScope selector(String? selector) => this(selector: selector);

  @override
  LogScope index(String? index) => this(index: index);

  @override
  LogScope streams(List<String>? streams) => this(streams: streams);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogScope(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogScope(...).copyWith(id: 12, name: "My name")
  /// ````
  LogScope call({
    Object? selector = const $CopyWithPlaceholder(),
    Object? index = const $CopyWithPlaceholder(),
    Object? streams = const $CopyWithPlaceholder(),
  }) {
    return LogScope(
      selector: selector == const $CopyWithPlaceholder()
          ? _value.selector
          // ignore: cast_nullable_to_non_nullable
          : selector as String?,
      index: index == const $CopyWithPlaceholder()
          ? _value.index
          // ignore: cast_nullable_to_non_nullable
          : index as String?,
      streams: streams == const $CopyWithPlaceholder()
          ? _value.streams
          // ignore: cast_nullable_to_non_nullable
          : streams as List<String>?,
    );
  }
}

extension $LogScopeCopyWith on LogScope {
  /// Returns a callable class that can be used as follows: `instanceOfLogScope.copyWith(...)` or like so:`instanceOfLogScope.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogScopeCWProxy get copyWith => _$LogScopeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogScope _$LogScopeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogScope', json, ($checkedConvert) {
      final val = LogScope(
        selector: $checkedConvert('selector', (v) => v as String?),
        index: $checkedConvert('index', (v) => v as String?),
        streams: $checkedConvert(
          'streams',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LogScopeToJson(LogScope instance) => <String, dynamic>{
  'selector': ?instance.selector,
  'index': ?instance.index,
  'streams': ?instance.streams,
};
