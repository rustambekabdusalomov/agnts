//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// chat: the assistant answers about the workspace. code: the conversation drives tickets that change repositories
enum ChatMode {
      @JsonValue(r'chat')
      chat(r'chat'),
      @JsonValue(r'code')
      code(r'code');

  const ChatMode(this.value);

  final String value;

  @override
  String toString() => value;
}
