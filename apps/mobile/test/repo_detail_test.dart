import 'package:agnts_api/agnts_api.dart';
import 'package:agnts_mobile/features/repos/commit_screen.dart';
import 'package:agnts_mobile/features/repos/repo_ci.dart';
import 'package:agnts_mobile/features/repos/repo_code.dart';
import 'package:agnts_mobile/features/repos/repo_diff.dart';
import 'package:agnts_mobile/features/repos/repo_guardrails.dart';
import 'package:agnts_mobile/features/repos/repo_members.dart';
import 'package:agnts_mobile/features/tickets/diff_lines.dart';
import 'package:flutter_test/flutter_test.dart';

Pipeline _p(CI s) => Pipeline(id: 1, name: '', branch: '', sha: '', message: '', trigger: '', status: s, durationMs: 0, url: '', stages: const []);

void main() {
  group('code browser', () {
    test('crumbs and parent', () {
      expect(crumbsOf('a/b/c').map((c) => c.path), ['a', 'a/b', 'a/b/c']);
      expect(crumbsOf(''), isEmpty);
      expect(parentOf('a/b/c'), 'a/b');
      expect(parentOf('a'), '');
      expect(parentOf(''), '');
    });

    test('readme and markdown names', () {
      expect(isReadme('README.md'), isTrue);
      expect(isReadme('readme'), isTrue);
      expect(isReadme('README.go'), isFalse);
      expect(isMarkdown('docs/a.MD'), isTrue);
      expect(isMarkdown('a.txt'), isFalse);
    });

    test('sizes', () {
      expect(fmtBytes(512), '512 B');
      expect(fmtBytes(1536), '1.5 KB');
      expect(fmtBytes(3 * 1024 * 1024), '3.0 MB');
    });

    test('file lines are numbered context lines without the trailing newline', () {
      final ls = codeLines('a\nb\n');
      expect(ls.map((l) => l.text), [' a', ' b']);
      expect(ls.map((l) => l.neu), [1, 2]);
      expect(ls.every((l) => l.old == null && l.kind == DiffKind.plain), isTrue);
      expect(codeLines('').length, 1);
    });
  });

  test('glob lines drop blanks and spaces', () {
    expect(globLines(' release/* \n\n main\n'), ['release/*', 'main']);
  });

  test('members filter by username or name', () {
    final ms = [RepoMember(username: 'ann', name: 'Ann Lee', role: 'admin'), RepoMember(username: 'bob', role: 'write')];
    expect(filterMembers(ms, 'LEE').map((m) => m.username), ['ann']);
    expect(filterMembers(ms, 'bo').map((m) => m.username), ['bob']);
    expect(filterMembers(ms, '  ').length, 2);
  });

  group('commit', () {
    test('overall CI', () {
      expect(commitCi(const []), CI.none);
      expect(commitCi([_p(CI.ok), _p(CI.fail)]), CI.fail);
      expect(commitCi([_p(CI.ok), _p(CI.run)]), CI.run);
      expect(commitCi([_p(CI.skip), _p(CI.canceled)]), CI.skip);
      expect(commitCi([_p(CI.ok), _p(CI.skip)]), CI.ok);
    });

    test('message title and body', () {
      expect(splitMessage('Fix it\n\nBecause.\n'), ('Fix it', 'Because.'));
      expect(splitMessage('One line'), ('One line', ''));
    });
  });

  group('guardrails form', () {
    test('derived checks are left out, own checks are sent cleaned', () {
      final f = HarnessForm.of(RepoHarness(guardProfile: RepoHarnessGuardProfileEnum.strict));
      expect(f.profile, 'strict');
      expect(f.body().editChecks, isNull);
      f.ownChecks = true;
      f.checks = [CheckRow(name: ' gofmt ', globs: '**/*.go, , *.mod', cmd: ' gofmt -l {file} ', every: 30)];
      final c = f.body().editChecks!.single;
      expect(c.name, 'gofmt');
      expect(c.globs, ['**/*.go', '*.mod']);
      expect(c.cmd, 'gofmt -l {file}');
      expect(c.every, 30);
      expect(f.body().guardProfile, RepoHarnessInputGuardProfileEnum.strict);
    });

    test('the workspace profile is the empty one', () {
      final f = HarnessForm.of(RepoHarness());
      expect(f.profile, '');
      expect(f.body().guardProfile, RepoHarnessInputGuardProfileEnum.empty);
      expect(f.body().coverage!.threshold, 0);
    });
  });
}
