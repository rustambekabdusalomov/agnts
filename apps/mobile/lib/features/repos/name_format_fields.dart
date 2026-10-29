import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import 'manage_logic.dart';
import 'manage_widgets.dart';

/// The branch name and commit message formats, each with its placeholders
/// and an example: a repository's own, or a group's ([group]), which
/// replace its members' in the group's tickets (empty keeps each
/// repository's own). [onChanged] runs as either is typed.
class NameFormatFields extends StatelessWidget {
  const NameFormatFields({
    super.key,
    required this.branch,
    required this.commit,
    required this.taskPrefix,
    this.branchPrefix = '',
    this.group = false,
    this.onChanged,
  });
  final TextEditingController branch;
  final TextEditingController commit;
  final String taskPrefix;
  final String branchPrefix;
  final bool group;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final grey = TextStyle(fontSize: 12.5, color: c.ink3);
    // A group's empty branch format has no example: each repository names its own.
    final branchEx = group && branch.text.trim().isEmpty
        ? ''
        : branchExample(branch.text, branchPrefix: branchPrefix, taskPrefix: taskPrefix);
    final commitEx = commitExample(commit.text, taskPrefix: taskPrefix);
    Widget ph(List<(String, String)> list) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Fold(
        title: l.reposPlaceholders,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (k, v) in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$k  ',
                        style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2),
                      ),
                      TextSpan(text: v, style: grey),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ManageField(
          label: l.reposBranchTemplate,
          help: [
            group ? l.groupsBranchTemplateHelp('{key}', '{number}') : l.reposBranchTemplateHelp('{key}', '{number}', branchDefault),
            if (branchEx.isNotEmpty) l.reposBranchTemplateExample(branchEx),
          ].join('\n'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ManageInput(controller: branch, mono: true, hint: group ? null : branchDefault, maxLength: 100, onChanged: onChanged),
              ph([
                ('{prefix}', l.reposPhPrefix),
                ('{type}', l.reposPhType),
                ('{key}', l.reposPhKey),
                ('{number}', l.reposPhNumber),
                ('{slug}', l.reposPhSlug),
                ('{user}', l.reposPhUser),
              ]),
            ],
          ),
        ),
        ManageField(
          label: l.reposCommitTemplate,
          help: [
            group ? l.groupsCommitTemplateHelp : l.reposCommitTemplateHelp,
            if (commitEx.isNotEmpty) l.reposCommitTemplateExample(commitEx),
          ].join('\n'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ManageInput(controller: commit, mono: true, hint: commitPlaceholder, maxLength: 200, onChanged: onChanged),
              ph([
                ('{number}', l.reposPhNumber),
                ('{key}', l.reposPhKey),
                ('{type}', l.reposPhCommitType),
                ('{scope}', l.reposPhScope),
                ('{subject}', l.reposPhSubject),
                ('{title}', l.reposPhTitle),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
