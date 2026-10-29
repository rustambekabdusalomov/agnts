import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// "Send feedback": a title and a description for the platform's Admins,
/// with the current workspace as context.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  static const _max = 5000;
  final _title = TextEditingController();
  final _description = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _ready => !_busy && _title.text.trim().isNotEmpty && _description.text.trim().isNotEmpty;

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    if (api == null || !_ready) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await api.getFeedbackApi().sendFeedback(
        sendFeedbackRequest: SendFeedbackRequest(
          title: _title.text.trim(),
          description: _description.text.trim(),
          workspace: ref.read(currentWorkspaceProvider)?.slug,
        ),
      );
      if (!mounted) return;
      showSnack(context, l.feedbackSent);
      Navigator.of(context).maybePop();
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Scaffold(
      appBar: DetailBar(backLabel: l.mobileMore),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          PageHeader(title: l.feedbackTitle),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(l.feedbackLede, style: TextStyle(fontSize: 15, height: 1.45, color: c.ink2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _title,
                    maxLength: 120,
                    decoration: InputDecoration(labelText: l.feedbackTitleLabel, hintText: l.feedbackTitlePlaceholder, counterText: ''),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _description,
                    maxLength: _max,
                    minLines: 6,
                    maxLines: 12,
                    decoration: InputDecoration(
                      labelText: l.feedbackDescLabel,
                      hintText: l.feedbackDescPlaceholder,
                      alignLabelWithHint: true,
                      counterText: l.maccountChars('${_description.text.length}', '$_max'),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: HelpBox(_error!, tone: Tone.bad),
                    ),
                  const SizedBox(height: 14),
                  FilledButton(onPressed: _ready ? _send : null, child: Text(l.feedbackSend)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
