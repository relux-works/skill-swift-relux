# TASK-260720-21f16m: configure-project-agent-runtime

## Description
Configure this repository agent runtime: enable task-board spawning, pin Codex child runs to gpt-5.6-sol with xhigh reasoning, and enable Codex primary-session yolo mode through the project-local agents-infra config. Keep generated runtime copies and shims out of version control while preserving the project config.

## Scope
task-board.config.json, .agents/.configs/project-config.toml, generated-runtime ignore rules, README tool documentation, and effective-config validation only.

## Acceptance Criteria
task-board project_config reports spawn.enabled=true and Codex gpt-5.6-sol/xhigh; agents-infra doctor and codex --print-config report project yolo_mode=true and the dangerous-mode argv expansion; only source-worthy config is tracked; generated runtime directories remain ignored.
