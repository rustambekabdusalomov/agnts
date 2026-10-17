import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

// Small building blocks shared by the workspace management screens:
// repositories, integrations, private networks and Claude chat (MCP).

/// "just now" or "5m ago" for a past time.
String agoText(AppLocalizations l, DateTime at) {
  final d = DateTime.now().difference(at);
  return d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d));
}

/// A labelled form field (.field): label, the input, and grey help under it.
class ManageField extends StatelessWidget {
  const ManageField({super.key, required this.label, required this.child, this.help});
  final String label;
  final String? help;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2)),
        ),
        child,
        if (help != null && help!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(help!, style: TextStyle(fontSize: 12.5, height: 1.35, color: c.ink3)),
          ),
      ]),
    );
  }
}

/// A text input with the app's look; [mono] for URLs, keys and commands.
class ManageInput extends StatelessWidget {
  const ManageInput({
    super.key,
    required this.controller,
    this.hint,
    this.mono = false,
    this.obscure = false,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.enabled = true,
    this.maxLength,
  });
  final TextEditingController controller;
  final String? hint;
  final bool mono;
  final bool obscure;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int? maxLength;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        minLines: minLines,
        maxLines: obscure ? 1 : maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        autocorrect: !mono,
        enableSuggestions: !mono && !obscure,
        onChanged: onChanged,
        style: mono ? const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13.5) : null,
        decoration: InputDecoration(hintText: hint, counterText: ''),
      );
}

/// A label and value on one line (.mini-kv), the value selectable.
class KvRow extends StatelessWidget {
  const KvRow(this.label, this.value, {super.key, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: TextStyle(fontSize: 13.5, color: c.ink3))),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink, fontFamily: mono ? AgntsFonts.mono : null),
          ),
        ),
      ]),
    );
  }
}

/// A value to paste somewhere else (.copy-field): label, the value in mono, a copy button.
class CopyLine extends StatelessWidget {
  const CopyLine(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 2, 4),
          decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Expanded(child: SelectableText(value, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink))),
            CopyButton(value),
          ]),
        ),
      ]),
    );
  }
}

/// A switch with a title and help, like the web's CfgRow + SwitchToggle.
class SwitchLine extends StatelessWidget {
  const SwitchLine({super.key, required this.title, required this.value, required this.onChanged, this.help});
  final String title;
  final String? help;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 15, color: c.ink)),
            if (help != null) Text(help!, style: TextStyle(fontSize: 12.5, color: c.ink3)),
          ]),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ]),
    );
  }
}

/// A card heading: bold title and grey subtitle (.ch h2 + .sub).
class CardTitle extends StatelessWidget {
  const CardTitle(this.title, {super.key, this.sub, this.trailing});
  final String title;
  final String? sub;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink)),
            if (sub != null && sub!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(sub!, style: TextStyle(fontSize: 13.5, height: 1.35, color: c.ink3)),
              ),
          ]),
        ),
        if (trailing != null) Padding(padding: const EdgeInsets.only(left: 8), child: trailing!),
      ]),
    );
  }
}

/// A card with side padding, as the management screens stack them.
Widget padCard(Widget child) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: HCard(child: child),
    );

/// Asks before an action; true when confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool danger = false,
}) async {
  final l = AppLocalizations.of(context);
  final c = Agnts.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.mobileCancel)),
        FilledButton(
          style: danger ? FilledButton.styleFrom(backgroundColor: c.bad) : null,
          onPressed: () => Navigator.pop(d, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Opens [child] as a tall bottom sheet, the app's drawer on a phone.
Future<T?> showManageSheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
      builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom), child: child),
    );

/// A sheet's title row: title, grey subtitle and a close button.
class SheetTitle extends StatelessWidget {
  const SheetTitle(this.title, {super.key, this.sub});
  final String title;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (sub != null) Padding(padding: const EdgeInsets.only(top: 3), child: Text(sub!, style: TextStyle(fontSize: 13.5, color: c.ink3))),
          ]),
        ),
        const SizedBox(width: 12),
        RoundIconButton('close', tooltip: l.navClose, onTap: () => Navigator.pop(context)),
      ]),
    );
  }
}

/// The red error line of a form (.ferr).
class ErrorLine extends StatelessWidget {
  const ErrorLine(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: TextStyle(fontSize: 14, color: Agnts.of(context).badInk)),
      );
}
