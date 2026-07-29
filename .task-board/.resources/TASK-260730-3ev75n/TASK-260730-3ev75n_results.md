# Corrected Handoff Summary

- Removed temporal connection from direct Relux/Dispatcher exceptions.
- Documented root environment injection, declarative `.reluxTemporal(state:)` attachment, view-owned lifetime, weak store retention, and no explicit cleanup.
- Removed `onConnect` dispatch examples; canonical view call sites neither read
  runtime state nor obtain a dispatcher.
- Documented that temporal state is not currently a stable injectable
  Flow/Saga dependency, with immutable `Sendable` snapshots and
  lifecycle-stable dependencies as current alternatives and a future runtime
  accessor direction clearly marked non-current.
- Preserved host-provider lifecycle and isolated integration-test dispatcher exceptions plus actor/MainActor isolation guidance.
- Final reinstall and source/installed validation are recorded in the current
  validation outcome.
