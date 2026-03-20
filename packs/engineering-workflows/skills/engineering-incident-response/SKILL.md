---
name: engineering-incident-response
description: Use when triaging a production incident, drafting status updates, assessing severity, coordinating mitigation, or writing a blameless postmortem after resolution.
---

# Engineering Incident Response

Manage an incident from first alert through mitigation and postmortem.

## Good Fits

- severity assessment for a new alert or outage
- drafting a status update mid-incident
- building the first postmortem after resolution

## Phases

1. Triage: severity, affected systems, impacted users, roles
2. Communicate: status updates, customer messaging, cadence
3. Mitigate: timeline, actions taken, resolution verification
4. Postmortem: root cause, 5 whys, action items, lessons learned

## Severity Guide

- SEV1: service down, all users affected
- SEV2: major feature degraded, many users affected
- SEV3: limited impact
- SEV4: low-impact issue

## Useful Inputs

- incident description or alert text
- affected systems, users, and timeline if known
- current status: investigating, identified, monitoring, or resolved
- any communications already sent

## Output Shapes

- incident update
- timeline
- blameless postmortem with action items

## Connected Tools

If connector categories are available:

- monitoring: alerts, graphs, metrics
- incident management: incident records and on-call escalation
- chat: internal status updates or war room coordination

## Common Mistakes

- using vague status updates that hide impact or next steps
- mixing speculation with confirmed facts
- writing a postmortem that blames people instead of systems and process gaps
