import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for RunTranscriptEvent
void main() {
  final RunTranscriptEvent? instance = /* RunTranscriptEvent(...) */ null;
  // TODO add properties to the entity

  group(RunTranscriptEvent, () {
    // init, text, tool, tool_result, rate_limit, result or note; clients show kinds they do not know as is
    // String k
    test('to test the property `k`', () async {
      // TODO
    });

    // int t
    test('to test the property `t`', () async {
      // TODO
    });

    // text, result, note: the text
    // String text
    test('to test the property `text`', () async {
      // TODO
    });

    // tool, tool_result: pairs a result with its call
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // tool: the tool (Bash, Read, Edit…)
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // tool: a one-line summary of the call
    // String summary
    test('to test the property `summary`', () async {
      // TODO
    });

    // tool: the input as given (an object), or as text when it was too big to keep as JSON (cut is then set)
    // Object input
    test('to test the property `input`', () async {
      // TODO
    });

    // tool_result: what the tool returned
    // String output
    test('to test the property `output`', () async {
      // TODO
    });

    // tool_result, result: it failed
    // bool error
    test('to test the property `error`', () async {
      // TODO
    });

    // tool_result: a command's exit code (Codex)
    // int exitCode
    test('to test the property `exitCode`', () async {
      // TODO
    });

    // The original length in bytes when the content was shortened
    // int cut
    test('to test the property `cut`', () async {
      // TODO
    });

    // result: success, error_max_turns…
    // String subtype
    test('to test the property `subtype`', () async {
      // TODO
    });

    // result: turns taken
    // int turns
    test('to test the property `turns`', () async {
      // TODO
    });

    // result: cost in USD
    // num cost
    test('to test the property `cost`', () async {
      // TODO
    });

    // rate_limit: the plan usage status
    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // init: the Claude Code session
    // String sessionId
    test('to test the property `sessionId`', () async {
      // TODO
    });

    // init: the model Claude Code reported
    // String model
    test('to test the property `model`', () async {
      // TODO
    });

  });
}
