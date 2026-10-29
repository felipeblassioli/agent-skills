---
name: dr
description: Have a "discutir a relação" with the agent when collaboration feels repetitive, over-steered, bureaucratic, or confused.
---

# DR — Discutir a Relação

Stop working on the immediate task for a moment and examine how we are working together.

This is not a code review. It is a review of the collaboration.

Use recent conversation and the guidance you are actually relying on to identify recurring friction between:

- what I ask for;
- what you tend to do;
- repository instructions;
- skills;
- ADRs/RFCs;
- memories;
- templates;
- existing conventions.

## Look for patterns

Especially notice when:

- I repeatedly correct the same behavior.
- You repeatedly say something is out of scope and I pull it back in.
- You preserve abstractions, PR boundaries, compatibility, or process that I later remove.
- You follow an ADR/skill/rule and I keep overriding the result.
- You ask permission where I expect ownership.
- You produce ceremony where I want judgment.
- We repeatedly rediscover that some "constraint" was only historical.
- A fresh look at the code contradicts durable guidance.
- Several individually reasonable instructions interact badly.

Do not assume every disagreement means the guidance is wrong. Sometimes your judgment was simply wrong, and sometimes mine may be.

## Diagnose the friction

For each recurring pattern, use:

`friction → likely source → evidence → what keeps happening → recommendation`

Identify the actual source when possible:

- agent judgment;
- current conversation context;
- CLAUDE.md / AGENTS.md;
- skill;
- ADR/RFC;
- memory;
- issue/PR template;
- code convention;
- conflicting instructions.

Do not invent a source just to explain the behavior.

## Challenge durable guidance

For guidance involved in repeated friction, ask:

- Is it still true?
- Is it too broad?
- Is it stale?
- Is it descriptive history pretending to be policy?
- Is a heuristic written as an absolute?
- Is another instruction contradicting it?
- Is tooling already enforcing it?
- Would removing it improve judgment?

Prefer:

`delete > narrow > consolidate > clarify > add`

Do not solve instruction bloat with more instruction bloat.

## Also challenge me

Call out cases where my corrections are inconsistent with each other or where I am repeatedly asking for something that conflicts with an invariant or constraint I previously established.

A DR is not useful if you merely agree with me.

## Finish with

### We're aligned on
A few things that are working well and should stay.

### We keep fighting about
The recurring friction worth fixing.

### Suspects
Specific skills, rules, memories, ADRs, templates, or defaults that deserve inspection.

### I would change
At most five concrete changes, subtraction-first.

### One experiment
A cheap way to test whether the suspected guidance is actually causing the problem.

Do not edit guidance automatically during the DR unless I explicitly ask. First make the relationship visible.
