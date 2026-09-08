# Research and validation

## Scope and sources

Seven ecosystem snapshots and relevant package/API evidence are recorded in
`references/overview/ecosystem.md`. The source repo is this checkout, not an
installed runtime. This repository ships Markdown and installer tests, not an
app target; no unrelated Swift platform builds were run.

- curator: https://github.com/relux-works/curator/tree/a16b6cb49544141b806795e6340a4729120f033a
- curator-spec: https://github.com/relux-works/curator-spec/tree/d019f0e7179520b5c8dcde321c4fe51e04552f58
- Curator tested: v0.14.1-0.20260907213730-04550e282705.
- Pi tested: 0.84.2, installed real `dist/core/skills.js` loader; explicit path,
  zero diagnostics, skill included in formatted model context. No LLM request.
- Upstream Pi discovery: https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md
- OpenCode discovery: https://opencode.ai/docs/skills/
- Claude format: https://code.claude.com/docs/en/skills

## Findings and decisions

- Curator drops top-level instructions/snippets; moved both into references.
- Package uses schema 3 for explicit no-runtime capabilities; no dependencies,
  command shims, hooks or MCPs are needed for a documentation skill.
- Narrowed generic analytics/localization triggers to Relux projects.
- Added pinned package map, version/platform caveats, dispatch ordering,
  non-transactional batches, ActionResult payload and analytics boundaries.
- Legacy installer now uses an explicit deliverable list and removes obsolete
  layout/configuration from the owned installed copy during upgrades.
- Optional standard compatibility frontmatter was omitted because the installed
  Codex validator rejects it; the shared name/description subset is sufficient.
- Package remains at existing source root; installed folder is swift-relux,
  matching the portable name. No source relocation or duplicate skill required.

## Validation

- `curator skill check .`: PASS.
- Codex `quick_validate.py .`: PASS.
- `python3 tests/package_test.py`: PASS; 22 context files, all local links.
- `python3 tests/curator_install_test.py`: PASS, signed snapshot
  `2dabbab992c7647e06dfe558d92b25b846cfbe01`.
  Evidence: `.temp/curator-test-b5v6td8e/commands.log`.
  All 22 context files matched byte-for-byte in canonical context and Claude,
  Codex, Gemini, Cursor adapters. Source-only files absent; all installed links
  resolve. Status up-to-date and repeat installation passed.
- Pi loader: PASS, `.temp/relux-curator/pi-loader-02.json`.
- `zsh -n setup.sh`, `./tests/setup_test.sh`: PASS including damaged link,
  missing reference, obsolete layout and source-config upgrade cases.
  Evidence: `.temp/relux-curator/setup-test-03.log`.
- `git diff --check`: PASS.
- Self-review: accepted local implementation; no live-client discovery claims
  for untested clients and no Swift compilation claim.

## Invalidated evidence and limitations

The first path-substitution install resolved old HEAD c9123ed rather than the
working tree. Installed bytes exposed this, so that run is not migration proof.
Its status was unresolvable because the normal declaration source was absent.
The signed snapshot test replaces both observations with actual new content and
an up-to-date status. Do not use git path substitutions to validate dirty edits.

The CLI's `global init --help` routes to idempotent GlobalInit rather than help;
inspection found an existing populated global Skillfile, which EnsureEmpty
preserves. No global skill was added or replaced.

Fixtures retain configured human identity and verified SSH signatures. They are
local test artifacts only and were not published. The feature branch is
`feat/curator-skill-package`, based on fetched origin/main c9123ed.

## Delivery authorization

The user confirmed task commit, publication, PR review and signed-head landing
on 2026-09-09. No product or packaging decisions remain unresolved. Delivery
proceeds on `feat/curator-skill-package`; remote review and checks must accept
the exact signed head before landing.
