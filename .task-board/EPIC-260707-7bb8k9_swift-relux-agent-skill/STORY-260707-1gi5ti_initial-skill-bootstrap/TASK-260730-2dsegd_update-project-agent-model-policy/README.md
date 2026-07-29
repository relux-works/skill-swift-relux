# TASK-260730-2dsegd: update-project-agent-model-policy

## Description
Update the project agent runtime and task-board spawn policy to Claude Opus 5 and Codex GPT-5.6 Sol with high reasoning, preserve yolo mode for both primary providers, remove any project fast-mode override, and retain the owner commit-timing policy.

## Scope
.agents/.configs/project-config.toml and task-board.config.json as tracked source policy; regenerate ignored .codex/config.toml through agents-infra; narrow effective-config validation only.

## Acceptance Criteria
Primary launcher policy resolves Claude Opus 5 and Codex GPT-5.6 Sol/high with yolo enabled; task-board spawn preflight resolves the analogous models/effort; no project fast override remains; version-control acknowledgement retains the after-20:00-MSK timestamp preference.
