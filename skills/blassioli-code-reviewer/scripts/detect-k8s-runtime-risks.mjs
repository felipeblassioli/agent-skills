#!/usr/bin/env node
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';

const root = process.argv[2] ?? process.cwd();
const ignored = new Set(['node_modules', '.git', 'dist', 'build', 'coverage']);
const yamlExt = /\.(ya?ml)$/i;

function walk(dir, out = []) {
  for (const name of readdirSync(dir)) {
    if (ignored.has(name)) continue;
    const path = join(dir, name);
    const st = statSync(path);
    if (st.isDirectory()) walk(path, out);
    else if (yamlExt.test(name)) out.push(path);
  }
  return out;
}

function includesAny(text, terms) {
  return terms.some((term) => text.includes(term));
}

function detectKind(text) {
  const match = text.match(/kind:\s*(Deployment|StatefulSet|DaemonSet|Job|CronJob)\b/i);
  return match ? match[1] : null;
}

function classifyWorkload(kind, text, path) {
  const combined = `${text}\n${path}`;
  const looksLikeWorker = /worker|consumer|subscriber|pubsub|queue|subscription|reconciler|backfill/i.test(combined);
  const looksLikeService = /service|api|http|grpc|ingress|gateway|cloud run|webhook/i.test(combined);

  if (kind === 'CronJob') return 'scheduled-job';
  if (kind === 'Job') return looksLikeWorker ? 'one-off-worker' : 'batch-job';
  if (looksLikeWorker) return 'long-lived-worker';
  if (looksLikeService) return 'request-driven-service';
  return 'long-lived-service';
}

const findings = [];
for (const file of walk(root)) {
  const text = readFileSync(file, 'utf8');
  const kind = detectKind(text);
  if (!kind) continue;

  const path = relative(root, file);
  const risks = [];
  const workloadType = classifyWorkload(kind, text, path);

  if (!text.includes('resources:')) risks.push('missing resources block');
  if (!text.includes('requests:')) risks.push('missing resource requests');
  if (!text.includes('limits:')) risks.push('missing resource limits');
  if (!text.includes('serviceAccountName:')) risks.push('missing explicit serviceAccountName');

  if (kind === 'Deployment' || kind === 'StatefulSet' || kind === 'DaemonSet') {
    if (!text.includes('terminationGracePeriodSeconds:')) risks.push('missing terminationGracePeriodSeconds');
    if (!text.includes('livenessProbe:')) risks.push('missing livenessProbe');

    if (workloadType === 'request-driven-service' || workloadType === 'long-lived-service') {
      if (!text.includes('readinessProbe:')) risks.push('missing readinessProbe');
    }

    if (workloadType === 'long-lived-worker' && !/preStop:|SIGTERM|terminationGracePeriodSeconds:/i.test(text)) {
      risks.push('worker-like workload without visible shutdown or drain hint');
    }
  }

  if (kind === 'Job') {
    if (!text.includes('backoffLimit:')) risks.push('missing backoffLimit');
    if (!text.includes('activeDeadlineSeconds:')) risks.push('missing activeDeadlineSeconds');
    if (!text.includes('ttlSecondsAfterFinished:')) risks.push('missing ttlSecondsAfterFinished');
  }

  if (kind === 'CronJob') {
    if (!text.includes('concurrencyPolicy:')) risks.push('missing concurrencyPolicy');
    if (!text.includes('startingDeadlineSeconds:')) risks.push('missing startingDeadlineSeconds');
    if (!text.includes('successfulJobsHistoryLimit:')) risks.push('missing successfulJobsHistoryLimit');
    if (!text.includes('failedJobsHistoryLimit:')) risks.push('missing failedJobsHistoryLimit');
    if (!text.includes('backoffLimit:')) risks.push('missing jobTemplate.spec.backoffLimit');
    if (!text.includes('activeDeadlineSeconds:')) risks.push('missing jobTemplate.spec.activeDeadlineSeconds');
  }

  if (risks.length > 0) findings.push({ file: path, kind, workloadType, risks });
}

console.log(JSON.stringify({ root, findings }, null, 2));
