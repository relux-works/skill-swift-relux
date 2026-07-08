## Status
to-review

## Assigned To
codex

## Created
2026-07-07T14:39:45Z

## Last Update
2026-07-07T14:52:35Z

## Blocked By
- (none)

## Blocks
- (none)

## Checklist
- [x] Document that startup dispatch belongs in rendered content .task after Resolver resolution, not inside the resolver closure

## Notes
Rule to document: Relux.Resolver resolver closure must only resolve/return Relux. Startup actions/effects that mutate state or navigation must run in rendered content .task after Resolver has applied .relux(relux) and passingObservableToEnvironment(fromStore:).

## Precondition Resources
- [TASK-260707-2glam4_swipe2cash-relux-bootstrap-research.md](file://TASK-260707-2glam4/TASK-260707-2glam4_swipe2cash-relux-bootstrap-research.md) — Local source research for Relux IoC bootstrap, Resolver state propagation, and dispatcher helpers

## Outcome Resources
- [TASK-260707-2glam4_outcome.md](file://TASK-260707-2glam4/TASK-260707-2glam4_outcome.md) — Skill documentation update and install verification notes
