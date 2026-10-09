import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import 'admin_data.dart';

/// Two letters on a small blue circle (.av), for lists of people.
class Initials extends StatelessWidget {
  const Initials(this.user, {super.key, this.size = 36});
  final User user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final words = nameOf(user).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2);
    final text = words.map((w) => w[0]).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
      child: Text(text.isEmpty ? '?' : text, style: TextStyle(color: c.primaryInk, fontSize: size * 0.38, fontWeight: FontWeight.w700)),
    );
  }
}

/// A person on one line: initials, name with a small line under it, and
/// something on the right (.adm-list li).
class PersonRow extends StatelessWidget {
  const PersonRow({super.key, required this.user, required this.sub, this.trailing, this.nameSuffix});
  final User user;
  final String sub;
  final Widget? trailing;
  final String? nameSuffix;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        Initials(user),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: nameOf(user)),
                if (nameSuffix != null) TextSpan(text: ' · $nameSuffix', style: TextStyle(color: c.ink3, fontWeight: FontWeight.w400)),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink),
            ),
            const SizedBox(height: 1),
            Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.ink3)),
          ]),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ]),
    );
  }
}

/// Filter chips with counts over a search field, as the cabinet's lists have.
class FilterBar<T> extends StatelessWidget {
  const FilterBar({super.key, required this.filters, required this.value, required this.onChanged, required this.hint, required this.onSearch});
  final List<(T, String, int)> filters;
  final T value;
  final ValueChanged<T> onChanged;
  final String hint;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SearchBox(hint: hint, onChanged: onSearch),
      ChipRow(children: [
        for (final (f, label, count) in filters) FilterChipH(label: label, count: count, selected: f == value, onTap: () => onChanged(f)),
      ]),
      const SizedBox(height: 10),
    ]);
  }
}

/// Asks before an action; true when confirmed.
Future<bool> confirmAction(BuildContext context, {required String title, String? body, required String action, bool danger = false}) async {
  final l = AppLocalizations.of(context);
  final c = Agnts.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.mobileCancel)),
        FilledButton(
          style: danger ? FilledButton.styleFrom(backgroundColor: c.bad, foregroundColor: Colors.white) : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// A labelled text field for the cabinet's forms (.field).
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.help,
    this.keyboard,
    this.obscure = false,
    this.autocorrect = true,
    this.maxLength,
    this.onChanged,
    this.formatters,
  });
  final String label;
  final TextEditingController controller;
  final String? help;
  final TextInputType? keyboard;
  final bool obscure;
  final bool autocorrect;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? formatters;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: c.ink)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: obscure,
          autocorrect: autocorrect && !obscure,
          enableSuggestions: autocorrect && !obscure,
          textCapitalization: TextCapitalization.none,
          maxLength: maxLength,
          onChanged: onChanged,
          inputFormatters: formatters,
          decoration: InputDecoration(counterText: '', helperText: help, helperMaxLines: 3),
        ),
      ]),
    );
  }
}

/// A bottom sheet with a title, a form and Cancel / [action] buttons. [submit]
/// returns an error message to show, or null when done (the sheet closes).
Future<bool> showFormSheet(
  BuildContext context, {
  required String title,
  String? sub,
  required String action,
  required List<Widget> Function(StateSetter setState) fields,
  required Future<String?> Function() submit,
  bool Function()? ready,
}) async {
  final done = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _FormSheet(title: title, sub: sub, action: action, fields: fields, submit: submit, ready: ready),
  );
  return done ?? false;
}

class _FormSheet extends StatefulWidget {
  const _FormSheet({required this.title, this.sub, required this.action, required this.fields, required this.submit, this.ready});
  final String title;
  final String? sub;
  final String action;
  final List<Widget> Function(StateSetter setState) fields;
  final Future<String?> Function() submit;
  final bool Function()? ready;

  @override
  State<_FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<_FormSheet> {
  bool _busy = false;
  String? _err;

  Future<void> _go() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    final err = await widget.submit();
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _busy = false;
      _err = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final ok = widget.ready?.call() ?? true;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          if (widget.sub != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(widget.sub!, style: TextStyle(fontSize: 14, color: c.ink3))),
          const SizedBox(height: 16),
          ...widget.fields(setState),
          if (_err != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_err!, style: TextStyle(color: c.badInk, fontSize: 13.5, fontWeight: FontWeight.w700)),
            ),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: _busy ? null : () => Navigator.pop(context, false), child: Text(l.mobileCancel))),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _busy || !ok ? null : _go,
                child: _busy
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.onPrimary))
                    : Text(widget.action, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// A grey "Loading…" or red error line inside a card.
class LoadLine extends StatelessWidget {
  const LoadLine({super.key, this.error = false});
  final bool error;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Text(error ? l.commonError : l.commonLoading, style: TextStyle(color: error ? c.badInk : c.ink3));
  }
}

/// The tone of a workspace's state badge.
Tone wsTone(PlatformWorkspace w) => w.deletedAt != null ? Tone.bad : (w.suspended ?? false) ? Tone.warn : Tone.ok;

/// A workspace's state label.
String wsState(AppLocalizations l, PlatformWorkspace w) =>
    w.deletedAt != null ? l.platformDeleted : (w.suspended ?? false) ? l.platformSuspended : l.platformActive;
