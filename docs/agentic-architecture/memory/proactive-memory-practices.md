# Layer: Memory

## Proactive Memory Practices

## Purpose
Define when and how memory should be updated proactively so future repository
work is faster, safer, and less repetitive.

## Update Without Being Asked
Write/update memory at checkpoints where decision context changes:
- after bootstrap,
- after discovering a new constraint or caveat,
- after selecting or changing an execution plan,
- after finding a reusable path/command pattern,
- before handoff or session end.

If no decision changed, do not update memory.

## Discovery Triggers for Updates
Capture updates when you discover:
- high-signal paths repeatedly needed for navigation,
- commands reused across related tasks,
- constraints that affect allowed actions,
- recurring failure modes or operational footguns,
- assumptions that were confirmed or invalidated,
- handoff details required to resume without re-analysis.

## Capture Decision-Shaping Information
Prefer compact entries that include:
- **fact**: what was learned,
- **impact**: which decision it affects,
- **scope**: where it applies,
- **confidence**: verified vs tentative,
- **next use**: how it should be reused.

Reject entries that cannot answer "what decision does this improve?"

## Prevent Memory Bloat
- Store conclusions, not raw command logs.
- Store canonical commands, not every variant tried.
- Store key paths, not full directory listings.
- Keep one entry per stable concept; merge duplicates.
- Avoid narrative history unless needed for future decisions.

## Prune Stale and Low-Value Entries
Prune during handoff or session close:
- delete resolved hypotheses with no future value,
- demote task-specific details from durable tiers,
- mark invalidated facts and replace with current truth,
- remove entries not reused over multiple checkpoints.

## Reuse Outcomes to Optimize
Memory should reduce repeated work in five loops:

1. **Repeated repo navigation**
   - maintain a short map of high-signal directories and entry files.
2. **Repeated command usage**
   - keep canonical command snippets with scope and caveats.
3. **Repeated risk detection**
   - capture recurring hazards and the corresponding pre-check.
4. **Repeated handoffs**
   - keep concise state packets: current focus, blockers, next action.
5. **Repeated task framing**
   - preserve durable constraints and architecture landmarks that shape scope.

## Compact Review Cadence
At natural checkpoints, run a quick review:
1. What changed decisions?
2. What will likely be reused?
3. What can be removed now?

This keeps memory selective, current, and operationally useful.
