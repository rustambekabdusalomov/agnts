//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_preview.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoPreview {
  /// Returns a new [RepoPreview] instance.
  RepoPreview({

    required  this.command,

    required  this.port,

    required  this.readyPath,

    required  this.routes,

    required  this.uiPaths,

    required  this.login,

    required  this.envSet,

    required  this.envNames,
  });

  @JsonKey(
    
    name: r'command',
    required: true,
    includeIfNull: false,
  )


  final String command;



  @JsonKey(
    
    name: r'port',
    required: true,
    includeIfNull: false,
  )


  final int port;



  @JsonKey(
    
    name: r'readyPath',
    required: true,
    includeIfNull: false,
  )


  final String readyPath;



  @JsonKey(
    
    name: r'routes',
    required: true,
    includeIfNull: false,
  )


  final List<String> routes;



  @JsonKey(
    
    name: r'uiPaths',
    required: true,
    includeIfNull: false,
  )


  final List<String> uiPaths;



  @JsonKey(
    
    name: r'login',
    required: true,
    includeIfNull: false,
  )


  final String login;



  @JsonKey(
    
    name: r'envSet',
    required: true,
    includeIfNull: false,
  )


  final bool envSet;



      /// The names of the variables in the environment; the values are never returned
  @JsonKey(
    
    name: r'envNames',
    required: true,
    includeIfNull: false,
  )


  final List<String> envNames;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoPreview &&
      other.command == command &&
      other.port == port &&
      other.readyPath == readyPath &&
      other.routes == routes &&
      other.uiPaths == uiPaths &&
      other.login == login &&
      other.envSet == envSet &&
      other.envNames == envNames;

    @override
    int get hashCode =>
        command.hashCode +
        port.hashCode +
        readyPath.hashCode +
        routes.hashCode +
        uiPaths.hashCode +
        login.hashCode +
        envSet.hashCode +
        envNames.hashCode;

  factory RepoPreview.fromJson(Map<String, dynamic> json) => _$RepoPreviewFromJson(json);

  Map<String, dynamic> toJson() => _$RepoPreviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

