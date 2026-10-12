# Rules

Rules tell agnts how your team works: how to test, name, log, structure code, and what never to touch. agnts follows them on every ticket and task.

## Global and repository rules

A global rule applies in every repository. A repository rule applies only there, and wins where it disagrees with a global rule.

## Review before use

When you save a rule, Claude reads it (for a repository rule, next to that repository's code) and checks it for vague words, missing scope, unhandled cases and conflicts with your other rules. If something is unclear, it asks. Your answers become part of the rule, and Claude reviews it again; after three rounds it settles on the most reasonable reading.

A rule applies only once it is clear. **Use as written** skips the open questions and applies the rule with the answers given so far.

## What tickets get

Every analysis and coding run gets the enabled rules that apply, under "Team rules", in Claude's clarified wording. The ticket's log says which rules it followed. Changing a rule's text sends it back to review; turning it off takes effect for the next run.

## Cost

A review is a short Claude run with the analysis model from Settings. It goes before waiting tickets, since every later ticket follows its result.

## Enforced rules

Give a rule a pattern and agnts-guard enforces it while Claude works: on edits of matching files (optionally only added lines matching a regular expression), on commands, or on the finished change. *Block* refuses the action; *Warn* tells Claude. Use **Try on history** to see what the pattern would have caught in agnts's last changes before you turn it on. A broken enforced rule also shows as a red flag in the review.

## Skills, tips and starter rules

A rule or business note delivered as a **skill** stays out of every prompt; Claude loads it when its description matches the work, which keeps prompts short as rules grow. Keep rules that must always apply in the prompt. **Tips** are practical lessons agnts learned from runs that had trouble; learned suggestions gain confidence each time agnts sees them again and are only *watched* until then, and one seen in two repositories is proposed for every repository. **Starter rules** for a repository's languages are offered on its page; adopting adds them as suggestions.
