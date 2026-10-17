import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

/// One CSV field, quoted when it holds a comma, quote or new line.
String csvField(Object? v) {
  final s = v == null ? '' : '$v';
  return RegExp(r'[",\n]').hasMatch(s) ? '"${s.replaceAll('"', '""')}"' : s;
}

/// Rows as CSV text, ending with a new line (as the admin panel exports it).
String toCsv(List<List<Object?>> rows) => '${rows.map((r) => r.map(csvField).join(',')).join('\n')}\n';

/// Asks where to save [text] as [name] (the system's save dialog), then
/// says whether it was saved. Cancelling says nothing.
Future<void> saveTextFile(BuildContext context, String name, String text, String mime) async {
  final l = AppLocalizations.of(context);
  try {
    final at = await FilePicker.saveFile(fileName: name, bytes: utf8.encode(text), mimeType: mime);
    if (at != null && context.mounted) showSnack(context, l.minsightsSaved(name));
  } catch (e) {
    if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
  }
}
