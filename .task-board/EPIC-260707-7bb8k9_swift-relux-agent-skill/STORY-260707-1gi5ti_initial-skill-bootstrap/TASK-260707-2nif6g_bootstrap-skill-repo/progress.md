## Status
to-review

## Assigned To
codex

## Created
2026-07-07T10:22:27Z

## Last Update
2026-07-07T10:27:29Z

## Blocked By
- (none)

## Blocks
- (none)

## Checklist
- [x] Scaffold standalone skill repo with git, ignore rules, and local board
- [x] Write SKILL.md with multilingual triggers and progressive reference routing
- [x] Move generic Relux module conventions and micro-spec into references
- [x] Add idempotent degitizing setup.sh and verify repeated install
- [x] Create GitHub remote and configure origin without committing or pushing
- [x] Review preserved alexis-agents-infra useful changes and rerun global setup
- [x] Run validation checks and record outcome

## Notes
Created standalone git repo with local task-board config, initial SKILL.md, Relux core/SwiftUI/router/module/package references, and genericized conventions from the previously leaked local instruction files. Verified no Tap2Cash/XPAirDrop/x-platform-airdrop legacy strings in skill sources.
Validated setup.sh syntax, ran setup twice successfully, and verified the installed copy under ~/.agents/skills/swift-relux is degitized and linked from ~/.claude/skills and ~/.codex/skills.
Created private GitHub repository relux-works/skill-swift-relux via gh and configured origin. No commit, staging, or push was performed.
Reviewed preserved alexis-agents-infra changes: kept browser no-focus policy, reusable workflow contract source rule, stop-the-line forced-fit workflow, and agents-infra caller cwd fix/tests; removed the remaining swipe2cash test fixture path. go test ./... passes and infra source project-specific hit check is empty before global setup.

## Precondition Resources
(none)

## Outcome Resources
- [TASK-260707-2nif6g_bootstrap-summary.md](file://TASK-260707-2nif6g/TASK-260707-2nif6g_bootstrap-summary.md) — Initial skill-swift-relux bootstrap summary
