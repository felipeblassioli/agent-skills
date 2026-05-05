# Verification Outputs

This directory stores curated, durable evidence from real validation scenarios.

It is intentionally small and stable. It should not become a second `.work/`
tree.

## What belongs here

Committed scenario folders should contain final artifacts such as:

- a filled-in discovery report
- a prompt matrix showing what was tested
- boundary checks that show whether the pack stayed in scope

## What does not belong here

Do not commit:

- raw transcripts
- terminal dumps
- repeated scratch runs
- huge generated inventories
- intermediate notes that are only useful during iteration

That material belongs in `.work/`.

## Current scenarios

- `bmad-method/`: first thorough validation against `tmp/BMAD-METHOD`
