# BUG-260720-pveoba: install-complete-degitized-skill-copy

## Description
Make setup.sh install a complete standalone swift-relux skill copy under the shared agents skill directory, exclude source-repository metadata, refresh Claude and Codex symlinks, and fail verification when any SKILL.md-linked local resource is missing. Preserve relocatability: the installed skill must not depend on the source checkout.

## Scope
swift-relux setup.sh, installer regression tests, README setup/tool documentation, and read-only comparison against the ios-app-manager installer/report. Do not modify unrelated board state or user changes.

## Acceptance Criteria
An isolated setup run copies every local resource referenced by SKILL.md, including instructions/module-authoring.md; the installed tree contains no Git, task-board, temp, or setup source artifacts; Claude and Codex entries are symlinks to the installed copy; verification detects an intentionally missing referenced resource; README documents the setup tool and artifact locations.
