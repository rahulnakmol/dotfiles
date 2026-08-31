#!/usr/bin/env node
/**
 * Apply agent-policy/catalog.json into Claude Code, Codex, Cursor, and
 * OpenCode adapters. Idempotent. Preserves unrelated settings (this repo's
 * Claude settings.json has no `autoMode` block — the macOS repo's version
 * of this script manipulates one; that block doesn't exist here and isn't
 * invented by this script, only permissions.deny/defaultMode/$schema are
 * touched).
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const catalog = JSON.parse(
  fs.readFileSync(path.join(ROOT, "agent-policy/catalog.json"), "utf8"),
);
const warning = fs.readFileSync(path.join(ROOT, "agent-policy/warning.md"), "utf8").trim();

function write(rel, contents) {
  const abs = path.join(ROOT, rel);
  fs.mkdirSync(path.dirname(abs), { recursive: true });
  fs.writeFileSync(abs, contents.endsWith("\n") ? contents : contents + "\n");
  console.log(`wrote ${rel}`);
}

function exists(rel) {
  return fs.existsSync(path.join(ROOT, rel));
}

function readJson(rel) {
  return JSON.parse(fs.readFileSync(path.join(ROOT, rel), "utf8"));
}

function secretPaths() {
  return [
    ...catalog.secrets.homePaths,
    ...catalog.secrets.systemPaths,
    ...catalog.secrets.workspaceGlobs,
  ];
}

function claudeDeny() {
  const deny = [];
  for (const p of secretPaths()) {
    deny.push(`Read(${p})`);
    deny.push(`Edit(${p})`);
  }
  return deny;
}

function ensureWarningSection(existing, marker) {
  if (existing.includes(marker)) {
    // NOT the "m" flag — with it, `$` matches end-of-LINE, not end-of-string.
    // Combined with the non-greedy [\s\S]*?, that collapses the match to
    // almost nothing (stops at the first line break after the heading), and
    // the warning gets INSERTED rather than replacing the section through to
    // EOF — confirmed against a real file with no heading after "## Secrets
    // ...": it duplicated the trailing paragraphs instead of replacing them.
    // Dropping "m" makes `$` mean true end-of-string, as the comment above always intended.
    const re = new RegExp(
      `##\\s+${marker.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}[\\s\\S]*?(?=\\n##\\s+|$)`,
    );
    if (re.test(existing)) {
      return existing.replace(re, warning + "\n\n").replace(/\n{3,}/g, "\n\n");
    }
  }
  return `${existing.trimEnd()}\n\n${warning}\n`;
}

function applyClaude() {
  const rel = catalog.adapters.claude.settings;
  const settings = readJson(rel);
  settings.$schema = catalog.schema.claudeSettings;
  settings.permissions = settings.permissions || {};
  settings.permissions.deny = claudeDeny();
  settings.permissions.defaultMode = settings.permissions.defaultMode || "auto";
  write(rel, JSON.stringify(settings, null, 2));

  const instrRel = catalog.adapters.claude.instructions;
  const instrPath = path.join(ROOT, instrRel);
  const instr = fs.existsSync(instrPath) ? fs.readFileSync(instrPath, "utf8") : "# Project Instructions\n";
  write(instrRel, ensureWarningSection(instr, catalog.warningMarker));

  write(
    catalog.adapters.claude.secretsRule,
    `---
description: Refuse secret file access and warn users not to paste credentials. Always on.
alwaysApply: true
---

${warning}

Also refuse Read/Edit of paths in \`agent-policy/catalog.json\` secrets (env files, keys, cloud credentials, SSH, kube, hosts.yml).
`,
  );
}

function applyCursor() {
  const cliRel = catalog.adapters.cursor.cliConfig;
  if (!exists(cliRel)) {
    console.log(`skip cursor: ${cliRel} not present yet`);
    return;
  }
  const cli = readJson(cliRel);
  const deny = [];
  for (const p of secretPaths()) {
    deny.push(`Read(${p})`);
    deny.push(`Write(${p})`);
  }
  for (const base of catalog.shell.cursorDenyShellBases) {
    deny.push(`Shell(${base})`);
  }
  cli.permissions = cli.permissions || {};
  cli.permissions.deny = deny;
  const allow = new Set(cli.permissions.allow || []);
  for (const base of catalog.shell.cursorAllowShellBases) {
    allow.add(`Shell(${base})`);
  }
  cli.permissions.allow = [...allow];
  write(cliRel, JSON.stringify(cli, null, 2));

  const ignoreLines = [
    "# Generated from agent-policy/catalog.json — do not hand-edit; re-run apply-agent-policy.mjs",
    ...catalog.secrets.workspaceGlobs.map((g) => g.replace(/^\*\*\//, "")),
    ".env",
    ".env.*",
    "!.env.example",
    "!*.env.example",
  ];
  write(catalog.adapters.cursor.cursorignore, ignoreLines.join("\n"));

  write(
    catalog.adapters.cursor.secretsRule,
    `---
description: Refuse secret file access and warn users not to paste credentials. Always on.
alwaysApply: true
---

${warning}

Trusted GitHub orgs (name OK when on those remotes): ${catalog.git.trustedOrgs.join(", ")}.
Other orgs: confidential — do not leak names into public destinations.

Git: feature push OK; protected branches (main/master/dev) only via PR; squash into dev then delete feature branch; merge dev→main and keep dev.
`,
  );

  const perms = {
    autoRun: {
      allow_instructions: [
        "Read-only git inspection and feature-branch work in trusted orgs is fine.",
        "Prefer podman over docker for containers.",
        "Rust cargo/rustc builds and tests are fine.",
      ],
      block_instructions: [
        "Block reading or writing secret files (.env, credentials, pem/key, SSH, cloud creds, kubeconfig, hosts.yml).",
        "Block pasting or echoing API keys, tokens, or private keys into the session.",
        "Require confirmation for git push to main/master/dev, force push, terraform apply/destroy, and cloud resource deletes.",
        "Require confirmation for az keyvault secret show and gcloud secrets versions access.",
      ],
    },
  };
  write(catalog.adapters.cursor.permissions, JSON.stringify(perms, null, 2));
}

function applyOpenCode() {
  const rel = catalog.adapters.opencode.config;
  const cfg = readJson(rel);
  cfg.permission = cfg.permission || {};
  const read = { "*": "allow" };
  const edit = { "*": "allow" };
  for (const p of catalog.secrets.workspaceGlobs) {
    read[p] = "deny";
    edit[p] = "deny";
  }
  for (const p of catalog.secrets.allowExceptions) {
    read[p] = "allow";
    edit[p] = "allow";
  }
  read["*.env"] = "deny";
  read["*.env.*"] = "deny";
  read["*.env.example"] = "allow";
  edit["*.env"] = "deny";
  edit["*.env.*"] = "deny";
  edit["*.env.example"] = "allow";

  const external = { "*": "allow" };
  for (const p of catalog.secrets.homePaths) {
    external[p] = "deny";
  }

  const bash = { "*": "allow" };
  for (const pat of catalog.shell.opencodeBashDeny) bash[pat] = "deny";
  for (const pat of catalog.shell.opencodeBashAsk) bash[pat] = "ask";

  cfg.permission = { read, edit, bash, external_directory: external };
  write(rel, JSON.stringify(cfg, null, 2));

  const agentsRel = catalog.adapters.opencode.agents;
  const agentsPath = path.join(ROOT, agentsRel);
  let agents = fs.existsSync(agentsPath) ? fs.readFileSync(agentsPath, "utf8") : "# OpenCode\n";
  agents = ensureWarningSection(agents, catalog.warningMarker);
  if (!agents.includes("Trusted GitHub orgs")) {
    agents += `\n\n## Git policy\nTrusted GitHub orgs: ${catalog.git.trustedOrgs.join(", ")}.\nFeature push OK; protected branches via PR only; squash→dev (delete branch); merge→main (keep dev).\nPrefer podman over docker.\n`;
  }
  write(agentsRel, agents);
}

// Codex has no per-path Read/Edit deny mechanism like the JSON-based agents —
// its coarsest sandbox knob is sandbox_mode (read-only/workspace-write), set
// per-profile in config.toml (Phase 3a's job). What this script owns for
// Codex is [shell_environment_policy].exclude — env-var NAME globs (AWS_*,
// not file paths), so it's driven by a different catalog field
// (secrets.envVarPrefixes) than the other three adapters. Patches an
// idempotent, marker-delimited block rather than rewriting the whole TOML,
// since config.toml has substantial hand-authored content (profiles,
// mcp_servers) this script has no business touching.
const CODEX_BEGIN = "# BEGIN agent-policy (managed by apply-agent-policy.mjs)";
const CODEX_END = "# END agent-policy";

function applyCodex() {
  const rel = catalog.adapters.codex.config;
  if (!exists(rel)) {
    console.log(`skip codex: ${rel} not present yet`);
    return;
  }
  const abs = path.join(ROOT, rel);
  const original = fs.readFileSync(abs, "utf8");
  const lines = original.split("\n");
  const startIdx = lines.indexOf(CODEX_BEGIN);
  const endIdx = lines.indexOf(CODEX_END);
  const before =
    startIdx === -1 ? lines : lines.slice(0, startIdx);
  const after =
    endIdx === -1 ? [] : lines.slice(endIdx + 1);

  const exclude = JSON.stringify(catalog.secrets.envVarPrefixes);
  const block = [
    CODEX_BEGIN,
    "[shell_environment_policy]",
    `exclude = ${exclude}`,
    "ignore_default_excludes = false",
    CODEX_END,
  ];

  const merged = [...before, ...block, ...after].join("\n");
  write(rel, merged);
}

applyClaude();
applyCursor();
applyOpenCode();
applyCodex();
console.log("apply-agent-policy: done");
