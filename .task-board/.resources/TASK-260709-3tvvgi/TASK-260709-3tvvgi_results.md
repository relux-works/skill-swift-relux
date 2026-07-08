# Relux presentation ingest results

Sources reviewed:
- `/Users/alexis/Downloads/UDF with Relux.key`, exported to PPTX/PDF under `.temp/presentation-relux-260709/`.
- Rendered deck slides 20-24, 35-57, and 67-74 for diagrams/code/caveats.
- `relux-works/relux-sample` logout cleanup flow.
- Membrana app logout cleanup flow and `Relux.IStore` wrapper.

Guidance added:
- Relux vs Redux mental model: store/state/reducer/dispatcher/middleware differences.
- Relux app boundary: product state, business event stream, SOA/service integration through sagas/flows, UI integration through containers.
- BusinessState -> UIState projection caveats: explicit one-way projection, no Combine escape hatch around actor isolation, no assumption that UIState is caught up immediately after dispatch.
- Three-layer modularity: enum namespaces, `Relux.Module`, SwiftPM packages.
- Flow/saga testing expectations: result, dispatched actions/effects, service calls, error/logger effects.
- Store cleanup on logout through `Relux.Store.cleanup(exclusions:)`, including app-shell exclusions.
- Logout transition pattern: route to `logoutInProgress` first so active SwiftUI view tasks cancel before store cleanup resets states.

Validation:
- `git diff --check`: `.temp/presentation-relux-260709/git-diff-check-02.log`
- `validate-skill.sh`: `.temp/presentation-relux-260709/validate-skill-02.log`
- `task-board validate`: `.temp/presentation-relux-260709/task-board-validate-01.log`
- `./setup.sh`: `.temp/presentation-relux-260709/setup-install-01.log`
