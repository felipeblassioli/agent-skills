# Production Safety

Production log investigation must balance debugging value with data minimization.

## Default posture

- assume production logs may contain sensitive application data
- start with narrow filters and small limits
- prefer metadata and short excerpts over full payloads
- summarize findings instead of pasting raw log arrays

## Query discipline

Use this order:

1. `resource.type`
2. `resource.labels.*`
3. time bounds
4. severity or HTTP status
5. text search or regex

Recommended defaults:

- discovery queries: `--limit=1` to `--limit=20`
- focused queries: `--limit=50` to `--limit=100`
- avoid broad unbounded reads in production

## Sensitive fields to redact or avoid echoing

Do not return raw values for:

- access tokens, API keys, bearer tokens, cookies, and authorization headers
- passwords, secrets, and credential-like strings
- full request or response bodies
- emails, phone numbers, and other personal identifiers unless strictly needed
- session IDs and customer-provided payloads unless the user explicitly asks

## Preferred evidence

Prefer returning:

- timestamps
- severity
- resource type and relevant labels
- trace IDs and request IDs
- counts and frequency patterns
- short redacted excerpts
- the likely root cause in plain language

## When raw content is unavoidable

If the parent explicitly asks for raw content:

1. summarize first
2. provide only the minimum excerpt needed
3. keep obvious sensitive values redacted
4. say that the excerpt was minimized because the source is production or sensitive

## Trace correlation

Trace IDs are high-value and usually lower risk than full payloads.

Use trace or request correlation to:

- connect request logs to application logs
- avoid broad text searches over large log sets
- explain causal chains without reproducing entire log entries

## Escalation boundary

If the investigation would require broad raw dumps of production payloads, stop
and ask the parent agent or user to confirm the higher-risk approach first.
