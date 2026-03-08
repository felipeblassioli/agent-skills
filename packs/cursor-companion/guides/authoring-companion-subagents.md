# Authoring Companion Subagents

The repository already has a strong pattern for pairing a reusable knowledge
surface with a runtime isolation surface:

- the `skill` decides when delegation is appropriate
- the `subagent` performs the noisy work in its own context window
- the `subagent` returns a structured summary instead of raw output

## Canonical examples

- `skills/test-verifier/SKILL.md` with `.cursor/agents/test-verifier.md`
- `skills/gcloud-logging/SKILL.md` with `.cursor/agents/log-reader.md`

## Design rules

- keep the subagent focused on one job
- put invocation hints in the `description`
- tell the parent exactly what inputs to provide
- define a compact output contract
- prefer `readonly: true` whenever the subagent does not need to edit files

## Minimal pattern

1. write a skill that explains when to delegate
2. create a subagent with a narrow role
3. add an output format that the parent can paste into a PR, report, or next step
4. add hooks only if runtime enforcement is required

## Anti-patterns

- giant general-purpose helper subagents
- raw logs or JSON pasted back to the parent
- long prompts with weak role definition
- using a subagent when a small direct tool call would do
