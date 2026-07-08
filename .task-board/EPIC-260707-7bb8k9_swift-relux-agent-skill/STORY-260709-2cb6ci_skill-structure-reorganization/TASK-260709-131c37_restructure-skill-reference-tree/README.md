# TASK-260709-131c37: restructure-skill-reference-tree

## Description
Split oversized Swift Relux skill guidance into a lean routing SKILL.md plus sectioned references, instruction entrypoints, and reusable snippets. Preserve the existing Relux guidance while making the loading path explicit for agents.

## Scope
Source skill repo only: SKILL.md, instructions/, references/, snippets/, and the installed copy refreshed through setup.sh. No product repositories or Relux libraries changed.

## Acceptance Criteria
SKILL.md routes to sectioned resources; detailed procedures live in instructions/; reusable examples live in snippets/; .refreshable performAsync guidance is documented; validation and setup smoke pass.
