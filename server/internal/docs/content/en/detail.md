# Ticket page

Follow one ticket from pickup to push. The track at the top shows where it is. Diamond steps are where agnts waits for you.

## Questions

agnts reads the code first and asks only what it can't decide itself. Pick an option or write your own answer, then press Start coding.

## Models for this ticket

Override the default model for this ticket only, for example Opus for a hard change or Haiku for a small one.

## Live log

While agnts works you see each step, the model, turns used and session usage. Stop run halts it and keeps the branch.

## Review

Read what agnts did and check the tests and diff. Approve and push commits as you. Request changes sends your feedback into the same session. Reject discards the branch.

## agnts's code review

While the work waits for you, agnts reviews it too: a diff for bugs, security, missing tests and your team rules; a report for accuracy and gaps. Findings appear above the diff, most severe first. It is a second opinion, never a gate: approve whenever you like. Add to feedback copies a finding's suggestion into your feedback, ready for Request changes. In Auto, Opus reviews complex tickets and Sonnet the rest.

## Follow-up tickets

Turn on Suggest follow-up tickets in Settings, or on one ticket, and agnts lists what finishing the ticket still needs: prerequisites and parts to split off (from the analysis), work it left undone (from the work), and gaps a plan, analysis or review found. It suggests nothing outside the ticket's goal; on a follow-up, the goal is that of the first ticket in the chain. Tick the ones you want and create them as local tasks or Jira issues. They are created queued, so nothing runs until you start them. Make follow-up turns a review finding into a suggestion. Suggestions from the work wait until the ticket is done.

## When agnts stops

After repeated failed tests or a plan limit, agnts stops instead of guessing. Add instructions and retry, or take the ticket yourself.

## History and run log

History lists the main moments. Run log shows every event grouped by step, and Open in Logs shows them with filters.

## Token spend

The Token spend card shows the tokens agnts's Claude runs used on this ticket: input and output in total, then one row per stage (analysis, coding, fixes and changes, code review, lessons) with its model. Cache reads and writes are listed apart because they are cheap and would swamp the rest. The track shows the same tokens under each step. The dollar figure is Claude Code's estimate at API prices; on a Claude plan it is not charged, but it shows which stages weigh most. A run that was stopped or timed out still counts, with its cost unknown.
