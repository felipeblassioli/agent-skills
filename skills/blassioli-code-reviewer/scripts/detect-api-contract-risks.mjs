#!/usr/bin/env node
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { basename, extname, join, relative } from 'node:path';

const root = process.argv[2] ?? process.cwd();
const ignored = new Set([
  'node_modules',
  '.git',
  'dist',
  'build',
  'coverage',
  '.next',
  '.turbo',
  '.nx',
]);
const exts = new Set(['.js', '.jsx', '.ts', '.tsx', '.mjs', '.cjs', '.json', '.yaml', '.yml']);
const openApiName = /(openapi|swagger)/i;

function walk(dir, out = []) {
  for (const name of readdirSync(dir)) {
    if (ignored.has(name)) continue;
    const path = join(dir, name);
    const st = statSync(path);
    if (st.isDirectory()) {
      walk(path, out);
      continue;
    }

    if (exts.has(extname(name)) || openApiName.test(name)) out.push(path);
  }
  return out;
}

function lineNumber(text, index) {
  return text.slice(0, index).split('\n').length;
}

function pushSmell(smells, file, text, smell, rx, evidenceOverride) {
  const match = rx.exec(text);
  if (!match) return;

  smells.push({
    file,
    line: lineNumber(text, match.index),
    smell,
    evidence: evidenceOverride ?? match[0].trim(),
  });
}

function looksLikeOpenApi(file, text) {
  return openApiName.test(basename(file)) || /\bopenapi:\s*3\.\d|\bswagger:\s*['"]?2/i.test(text);
}

function hasMutationHandler(text) {
  return /\.(post|put|patch|delete)\s*\(|@(Post|Put|Patch|Delete)\s*\(/.test(text);
}

function hasPostHandler(text) {
  return /\.(post)\s*\(|@Post\s*\(/.test(text);
}

function hasPatchHandler(text) {
  return /\.(patch)\s*\(|@Patch\s*\(/.test(text);
}

function hasIdempotencySignal(text) {
  return /Idempotency-Key|idempotency[-_ ]?key|request_id|requestId|dedup|dedupe|natural key|unique constraint|upsert/i.test(text);
}

function hasPatchSafetySignal(text) {
  return /updateMask|update_mask|fieldMask|field_mask|If-Match|ETag|etag|merge-patch|json patch|json merge patch|immutable|output[-_ ]only/i.test(text);
}

function hasPaginationTerms(text) {
  return /page_token|pageToken|page_size|pageSize|next_page_token|nextPageToken|cursor|limit|offset|hasMore/i.test(text);
}

const openapiFiles = [];
const routeFiles = [];
const smells = [];

for (const file of walk(root)) {
  let text;
  try {
    text = readFileSync(file, 'utf8');
  } catch {
    continue;
  }

  const rel = relative(root, file);
  const isOpenApi = looksLikeOpenApi(rel, text);
  if (isOpenApi) openapiFiles.push(rel);

  const routeLike = /\.(get|post|put|patch|delete)\s*\(|@(Get|Post|Put|Patch|Delete)\s*\(/.test(text);
  if (routeLike) routeFiles.push(rel);

  pushSmell(
    smells,
    rel,
    text,
    'VERB_IN_PATH',
    /['"`]\/[^'"`\n]*(?:create|get|delete|update|list|fetch|set|reset|execute|run|process)(?:\w|\/|:|-)*['"`]/i,
  );

  pushSmell(
    smells,
    rel,
    text,
    'AD_HOC_ERROR_SHAPE',
    /status\s*\(\s*(?:4\d\d|5\d\d)\s*\)\s*\.(?:json|send)\s*\(\s*\{\s*(?:error|message)\s*:/i,
  );

  if (hasPostHandler(text) && !hasIdempotencySignal(text)) {
    smells.push({
      file: rel,
      line: 1,
      smell: 'POST_WITHOUT_IDEMPOTENCY_SIGNAL',
      evidence: 'POST handler found without an obvious idempotency boundary signal',
    });
  }

  if (hasPatchHandler(text) && !hasPatchSafetySignal(text)) {
    smells.push({
      file: rel,
      line: 1,
      smell: 'PATCH_WITHOUT_EXPLICIT_MASK_OR_CONCURRENCY_SIGNAL',
      evidence: 'PATCH handler found without an obvious mask, immutability, or optimistic-concurrency signal',
    });
  }

  if (isOpenApi && /\/[^:\n]+:\s*\n(?:[^\n]*\n){0,8}\s{2,}(?:get|post|put|patch|delete):/i.test(text) && !hasPaginationTerms(text)) {
    smells.push({
      file: rel,
      line: 1,
      smell: 'SPEC_WITHOUT_VISIBLE_PAGINATION_TERMS',
      evidence: 'OpenAPI-like file found without obvious pagination terms; confirm collection endpoints are bounded',
    });
  }

  if (isOpenApi && !/application\/problem\+json|problem details|Problem Details/i.test(text) && /4\d\d|5\d\d/.test(text)) {
    smells.push({
      file: rel,
      line: 1,
      smell: 'SPEC_WITHOUT_PROBLEM_DETAILS_SIGNAL',
      evidence: 'OpenAPI-like file defines error responses without an obvious Problem Details signal',
    });
  }

  if (routeLike || isOpenApi || hasMutationHandler(text)) {
    continue;
  }
}

console.log(
  JSON.stringify(
    {
      root,
      openapiFiles,
      routeFiles,
      smells,
    },
    null,
    2,
  ),
);
