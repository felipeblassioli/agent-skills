#!/usr/bin/env node
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';

const root = process.argv[2] ?? process.cwd();
const ignored = new Set(['node_modules', '.git', 'dist', 'build', 'coverage', '.next', '.turbo', '.nx']);
const exts = new Set(['.js', '.jsx', '.ts', '.tsx', '.mjs', '.cjs', '.go', '.kt', '.java', '.py']);

const patterns = [
  ['pubsub-library', /@google-cloud\/pubsub|cloud\.google\.com\/go\/pubsub|google\.cloud\.pubsub/i],
  ['subscription', /subscription\(|Subscriber|subscribe\(|Receive\(|Pull\(|pubsub\.Subscription/i],
  ['ack-nack', /\.ack\(|\.nack\(|Ack\(|Nack\(|acknowledge|modifyAckDeadline/i],
  ['idempotency', /idempot|dedup|dedupe|inbox|processed_message|processedEvent|messageId|eventId/i],
  ['flow-control', /flowControl|maxOutstanding|maxMessages|maxBytes|concurrency|parallelism|workerPool/i],
  ['retry-dlq', /retry|dead.?letter|dlq|deliveryAttempt|maxDeliveryAttempts/i],
  ['shutdown', /SIGTERM|SIGINT|shutdown|drain|AbortController|context\.Canceled/i],
  ['risky-unbounded-parallelism', /Promise\.all\s*\(|forEach\s*\(\s*async|go func\s*\(/i],
];

function walk(dir, out = []) {
  for (const name of readdirSync(dir)) {
    if (ignored.has(name)) continue;
    const path = join(dir, name);
    const st = statSync(path);
    if (st.isDirectory()) walk(path, out);
    else {
      const dot = name.lastIndexOf('.');
      const ext = dot >= 0 ? name.slice(dot) : '';
      if (exts.has(ext)) out.push(path);
    }
  }
  return out;
}

const hits = [];
for (const file of walk(root)) {
  let text;
  try {
    text = readFileSync(file, 'utf8');
  } catch {
    continue;
  }
  const fileHits = [];
  for (const [label, rx] of patterns) {
    if (rx.test(text)) fileHits.push(label);
  }
  if (fileHits.length > 0) {
    hits.push({ file: relative(root, file), signals: fileHits });
  }
}

console.log(JSON.stringify({ root, candidates: hits }, null, 2));
