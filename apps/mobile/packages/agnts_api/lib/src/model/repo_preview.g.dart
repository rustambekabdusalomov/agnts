// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_preview.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoPreviewCWProxy {
  RepoPreview command(String command);

  RepoPreview port(int port);

  RepoPreview readyPath(String readyPath);

  RepoPreview routes(List<String> routes);

  RepoPreview uiPaths(List<String> uiPaths);

  RepoPreview login(String login);

  RepoPreview envSet(bool envSet);

  RepoPreview envNames(List<String> envNames);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoPreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoPreview(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoPreview call({
    String command,
    int port,
    String readyPath,
    List<String> routes,
    List<String> uiPaths,
    String login,
    bool envSet,
    List<String> envNames,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoPreview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoPreview.copyWith.fieldName(...)`
class _$RepoPreviewCWProxyImpl implements _$RepoPreviewCWProxy {
  const _$RepoPreviewCWProxyImpl(this._value);

  final RepoPreview _value;

  @override
  RepoPreview command(String command) => this(command: command);

  @override
  RepoPreview port(int port) => this(port: port);

  @override
  RepoPreview readyPath(String readyPath) => this(readyPath: readyPath);

  @override
  RepoPreview routes(List<String> routes) => this(routes: routes);

  @override
  RepoPreview uiPaths(List<String> uiPaths) => this(uiPaths: uiPaths);

  @override
  RepoPreview login(String login) => this(login: login);

  @override
  RepoPreview envSet(bool envSet) => this(envSet: envSet);

  @override
  RepoPreview envNames(List<String> envNames) => this(envNames: envNames);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoPreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoPreview(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoPreview call({
    Object? command = const $CopyWithPlaceholder(),
    Object? port = const $CopyWithPlaceholder(),
    Object? readyPath = const $CopyWithPlaceholder(),
    Object? routes = const $CopyWithPlaceholder(),
    Object? uiPaths = const $CopyWithPlaceholder(),
    Object? login = const $CopyWithPlaceholder(),
    Object? envSet = const $CopyWithPlaceholder(),
    Object? envNames = const $CopyWithPlaceholder(),
  }) {
    return RepoPreview(
      command: command == const $CopyWithPlaceholder()
          ? _value.command
          // ignore: cast_nullable_to_non_nullable
          : command as String,
      port: port == const $CopyWithPlaceholder()
          ? _value.port
          // ignore: cast_nullable_to_non_nullable
          : port as int,
      readyPath: readyPath == const $CopyWithPlaceholder()
          ? _value.readyPath
          // ignore: cast_nullable_to_non_nullable
          : readyPath as String,
      routes: routes == const $CopyWithPlaceholder()
          ? _value.routes
          // ignore: cast_nullable_to_non_nullable
          : routes as List<String>,
      uiPaths: uiPaths == const $CopyWithPlaceholder()
          ? _value.uiPaths
          // ignore: cast_nullable_to_non_nullable
          : uiPaths as List<String>,
      login: login == const $CopyWithPlaceholder()
          ? _value.login
          // ignore: cast_nullable_to_non_nullable
          : login as String,
      envSet: envSet == const $CopyWithPlaceholder()
          ? _value.envSet
          // ignore: cast_nullable_to_non_nullable
          : envSet as bool,
      envNames: envNames == const $CopyWithPlaceholder()
          ? _value.envNames
          // ignore: cast_nullable_to_non_nullable
          : envNames as List<String>,
    );
  }
}

extension $RepoPreviewCopyWith on RepoPreview {
  /// Returns a callable class that can be used as follows: `instanceOfRepoPreview.copyWith(...)` or like so:`instanceOfRepoPreview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoPreviewCWProxy get copyWith => _$RepoPreviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoPreview _$RepoPreviewFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoPreview', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'command',
          'port',
          'readyPath',
          'routes',
          'uiPaths',
          'login',
          'envSet',
          'envNames',
        ],
      );
      final val = RepoPreview(
        command: $checkedConvert('command', (v) => v as String),
        port: $checkedConvert('port', (v) => (v as num).toInt()),
        readyPath: $checkedConvert('readyPath', (v) => v as String),
        routes: $checkedConvert(
          'routes',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        uiPaths: $checkedConvert(
          'uiPaths',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        login: $checkedConvert('login', (v) => v as String),
        envSet: $checkedConvert('envSet', (v) => v as bool),
        envNames: $checkedConvert(
          'envNames',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RepoPreviewToJson(RepoPreview instance) =>
    <String, dynamic>{
      'command': instance.command,
      'port': instance.port,
      'readyPath': instance.readyPath,
      'routes': instance.routes,
      'uiPaths': instance.uiPaths,
      'login': instance.login,
      'envSet': instance.envSet,
      'envNames': instance.envNames,
    };
