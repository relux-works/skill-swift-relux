# Flight Logbook

> Institutional memory. Concise, factual, high-signal.
> Newest entries first. One block per insight.

## 2026-07-20

### 1542 — Installed skill copies could remain incomplete
- ROOT CAUSE: `swift-relux` and `ios-app-manager` source trees contain the reported resources, but their installers only verified `SKILL.md` or symlink presence; stale or damaged installed copies were not diagnosed as a resource-graph failure.
- FIX: `swift-relux/setup.sh` now verifies source-to-installed runtime parity and every local resource linked from `SKILL.md`; `--verify-only` detects drift without repair.
- FINDING: Current source and installed copies match for `instructions/module-authoring.md` and the referenced `ios-app-manager` PlantUML diagrams.
- SCOPE: `setup.sh`, `tests/setup_test.sh`, `README.md`, `BUG-260720-pveoba`.
- STATUS: `swift-relux` fixed and reinstalled; equivalent fail-loud verification remains pending in the `skill-ios-app-manager` source repository.
