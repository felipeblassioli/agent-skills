---
name: engineering-standup
description: Use when preparing a daily standup update, summarizing recent work into yesterday, today, and blockers, or turning rough notes and recent activity into a concise team update.
---

# Engineering Standup

Generate a concise standup update from recent work, plans, and blockers.

## Good Fits

- daily sync preparation
- turning scattered notes into a clean standup
- summarizing recent commits, ticket movement, or reviews into team language

## Input Options

- let connected tools supply the recent activity
- provide rough notes in plain language
- ask for Slack-, email-, or meeting-ready formatting

## Output Shape

```markdown
## Standup — [Date]

### Yesterday
### Today
### Blockers
```

## Connected Tools

If connector categories are available:

- source control: commits, PRs, reviews
- project tracker: ticket movement
- chat: discussions that matter for today's sync
- CI/CD: build or deploy status worth calling out

## Common Mistakes

- listing activity without clarifying progress or intent
- hiding blockers in the Yesterday section
- making the update too long for a daily sync

## Tips

1. Keep it action-oriented.
2. Mention blocker context and who can help.
3. Ask for Slack-, email-, or meeting-ready formatting if needed.
