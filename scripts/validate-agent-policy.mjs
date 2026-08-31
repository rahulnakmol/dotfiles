#!/usr/bin/env node
/**
 * Validate that Claude / Codex / Cursor / OpenCode adapters match
 * agent-policy/catalog.json. Prints a feedback report. Exit 1 on any fail.
 * Adapters whose target files don't exist yet report info, not fail — this
 * script runs from partway through the WSL/parity build, before every
 * adapter's files land.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const catalog = JSON.parse(
  fs.readFileSync(path.join(ROOT, "agent-policy/catalog.json"), "utf8"),
);

const findings = [];
let fails = 0;
let passes = 0;

function ok(area, msg, detail) {
  passes++;
  findings.push({ level: "pass", area, msg, detail });
}
function fail(area, msg, detail) {
  fails++;
  findings.push({ level: "fail", area, msg, detail });
}
function info(area, msg, detail) {
  findings.push({ level: "info", area, msg, detail });
}

function exists(rel) {
  return fs.existsSync(path.join(ROOT, rel));
}
function read(rel) {
  return fs.readFileSync(path.join(ROOT, rel), "utf8");
}
function readJson(rel) {
  return JSON.parse(read(rel));
}

function secretPaths() {
  return [
    ...catalog.secrets.homePaths,
    ...catalog.secrets.systemPaths,
    ...catalog.secrets.workspaceGlobs,
  ];
}

function checkWarningIn(rel, area) {
  if (!exists(rel)) {
    fail(area, `missing file ${rel}`);
    return;
  }
  const body = read(rel);
  if (body.includes(catalog.warningMarker)) {
    ok(area, `warning marker present in ${rel}`);
  } else {
    fail(area, `missing warning marker "${catalog.warningMarker}" in ${rel}`);
  }
  if (body.includes("1Password") || body.includes("zshrc.local")) {
    ok(area, `secret storage guidance present in ${rel}`);
  } else {
    fail(area, `missing 1Password / zshrc.local guidance in ${rel}`);
  }
}

function checkClaude() {
  const rel = catalog.adapters.claude.settings;
  if (!exists(rel)) {
    fail("claude", `missing ${rel}`);
    return;
  }
  let settings;
  try {
    settings = readJson(rel);
    ok("claude", "settings.json parses as JSON");
  } catch (e) {
    fail("claude", "settings.json is not valid JSON", String(e));
    return;
  }

  if (settings.$schema === catalog.schema.claudeSettings) {
    ok("claude", "$schema matches JSON Schema Store URL");
  } else {
    fail("claude", "$schema missing or stale", settings.$schema);
  }

  const deny = settings.permissions?.deny || [];
  const denySet = new Set(deny);
  let missingRead = 0;
  let missingEdit = 0;
  for (const p of secretPaths()) {
    if (!denySet.has(`Read(${p})`)) missingRead++;
    if (!denySet.has(`Edit(${p})`)) missingEdit++;
  }
  if (missingRead === 0) ok("claude", `all ${secretPaths().length} secret Read() denies present`);
  else fail("claude", `${missingRead} secret Read() denies missing`);
  if (missingEdit === 0) ok("claude", "all secret Edit() denies present");
  else fail("claude", `${missingEdit} secret Edit() denies missing`);

  if (settings.permissions?.defaultMode) {
    ok("claude", `defaultMode is set (${settings.permissions.defaultMode})`);
  } else {
    fail("claude", "defaultMode is unset");
  }

  checkWarningIn(catalog.adapters.claude.instructions, "claude");
  checkWarningIn(catalog.adapters.claude.secretsRule, "claude");
  info("claude", "deny rule count", String(deny.length));
}

function checkCursor() {
  const cliRel = catalog.adapters.cursor.cliConfig;
  if (!exists(cliRel)) {
    info("cursor", `${cliRel} not present yet`);
    return;
  }
  const cli = readJson(cliRel);
  const deny = new Set(cli.permissions?.deny || []);
  let missing = 0;
  for (const p of secretPaths()) {
    if (!deny.has(`Read(${p})`)) missing++;
  }
  if (missing === 0) ok("cursor", "cli-config deny covers all secret Read() paths");
  else fail("cursor", `cli-config missing ${missing} secret Read() denies`);

  for (const base of catalog.shell.cursorDenyShellBases) {
    if (deny.has(`Shell(${base})`)) ok("cursor", `Shell(${base}) denied`);
    else fail("cursor", `Shell(${base}) not denied`);
  }

  if (!exists(catalog.adapters.cursor.cursorignore)) {
    fail("cursor", "missing .cursorignore");
  } else {
    const ig = read(catalog.adapters.cursor.cursorignore);
    if (ig.includes(".env")) ok("cursor", ".cursorignore blocks .env");
    else fail("cursor", ".cursorignore missing .env");
  }

  checkWarningIn(catalog.adapters.cursor.secretsRule, "cursor");

  if (!exists(catalog.adapters.cursor.permissions)) {
    fail("cursor", "missing permissions.json");
  } else {
    const perms = readJson(catalog.adapters.cursor.permissions);
    const block = (perms.autoRun?.block_instructions || []).join("\n");
    if (block.toLowerCase().includes("secret")) {
      ok("cursor", "permissions.json autoRun blocks secrets");
    } else {
      fail("cursor", "permissions.json autoRun missing secret block instructions");
    }
  }
}

function checkOpenCode() {
  const rel = catalog.adapters.opencode.config;
  if (!exists(rel)) {
    fail("opencode", `missing ${rel}`);
    return;
  }
  const cfg = readJson(rel);
  const readPerm = cfg.permission?.read || {};
  const editPerm = cfg.permission?.edit || {};
  let missR = 0;
  let missE = 0;
  for (const g of catalog.secrets.workspaceGlobs) {
    if (readPerm[g] !== "deny") missR++;
    if (editPerm[g] !== "deny") missE++;
  }
  if (missR === 0) ok("opencode", "permission.read denies workspace secret globs");
  else fail("opencode", `${missR} read denies missing`);
  if (missE === 0) ok("opencode", "permission.edit denies workspace secret globs");
  else fail("opencode", `${missE} edit denies missing`);

  if (readPerm["*.env"] === "deny" && readPerm["*.env.example"] === "allow") {
    ok("opencode", ".env denied with .env.example allowed");
  } else {
    fail("opencode", ".env / .env.example read rules incorrect");
  }

  const bash = cfg.permission?.bash || {};
  for (const pat of catalog.shell.opencodeBashDeny) {
    if (bash[pat] === "deny") ok("opencode", `bash deny ${pat}`);
    else fail("opencode", `bash deny missing ${pat}`);
  }

  checkWarningIn(catalog.adapters.opencode.agents, "opencode");
}

function checkCodex() {
  const rel = catalog.adapters.codex.config;
  if (!exists(rel)) {
    info("codex", `${rel} not present yet`);
    return;
  }
  const body = read(rel);
  if (!body.includes("[shell_environment_policy]")) {
    fail("codex", "missing [shell_environment_policy] table");
    return;
  }
  ok("codex", "[shell_environment_policy] table present");
  let missing = 0;
  for (const prefix of catalog.secrets.envVarPrefixes) {
    if (!body.includes(`"${prefix}"`)) missing++;
  }
  if (missing === 0) ok("codex", `all ${catalog.secrets.envVarPrefixes.length} env-var exclude prefixes present`);
  else fail("codex", `${missing} env-var exclude prefixes missing`);

  if (body.includes("ignore_default_excludes = false") || !body.includes("ignore_default_excludes")) {
    ok("codex", "ignore_default_excludes not weakened (KEY/TOKEN/SECRET stripping stays on)");
  } else {
    fail("codex", "ignore_default_excludes is true — weakens built-in secret-name stripping");
  }

  if (/model_providers\.azure|AZURE_OPENAI_API_KEY|model_provider\s*=\s*"azure"/.test(body)) {
    fail("codex", "Azure model provider still present — Codex runs on ChatGPT auth now");
  } else {
    ok("codex", "no Azure model-provider wiring");
  }
  if (/approval_policy\s*=\s*"on-failure"/.test(body)) {
    fail("codex", 'approval_policy = "on-failure" is a deprecated alias for "on-request", not a stricter setting');
  } else {
    ok("codex", "no deprecated on-failure approval_policy spelling");
  }
  if (/sandbox_mode\s*=\s*"danger-full-access"/.test(body)) {
    fail("codex", "a profile sets sandbox_mode = danger-full-access");
  } else {
    ok("codex", "no profile sets danger-full-access");
  }
  if (/\[projects\."\/home\/rahulnakmol/.test(body)) {
    fail("codex", "[projects] entry hardcodes a specific user's home path");
  } else {
    ok("codex", "no hardcoded [projects] home path");
  }
}

checkClaude();
checkCursor();
checkOpenCode();
checkCodex();

console.log("\n=== Agent policy validation report ===\n");
for (const f of findings) {
  const tag = f.level.toUpperCase().padEnd(4);
  const detail = f.detail ? ` — ${f.detail}` : "";
  console.log(`[${tag}] ${f.area}: ${f.msg}${detail}`);
}
console.log(`\nSummary: ${passes} passed, ${fails} failed, ${findings.length} checks`);
console.log(
  fails === 0
    ? "Verdict: PASS — adapters match catalog intent."
    : "Verdict: FAIL — fix adapters (re-run node scripts/apply-agent-policy.mjs) then re-validate.",
);
process.exit(fails === 0 ? 0 : 1);
