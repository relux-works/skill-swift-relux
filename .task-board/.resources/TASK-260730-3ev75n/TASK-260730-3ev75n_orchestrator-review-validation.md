# Superseded Acceptance Review

The prior review classified temporal connection as an exact-runtime dispatch
exception. The owner corrected that interpretation after the review. Current
source and validation instead establish view-owned temporal state connected
declaratively through the environment runtime. Canonical view call sites use
`.reluxTemporal(state:)` without `onConnect` runtime/dispatcher access.

See `TASK-260730-3ev75n_swiftui-relux-temporal-evidence.md` and the current
validation outcome. Prior validation logs remain historical evidence for the
earlier revision only.
