# Module Authoring Workflow

Use this workflow when adding or reviewing a Relux feature module.

- Read [../references/modules/module-conventions.md](../references/modules/module-conventions.md)
  for module shape, namespace naming, reducers, flow/saga rules, tests, and
  analytics.
- Read [../references/core/relux-core.md](../references/core/relux-core.md) for
  state, action, effect, reducer, dispatch, flow, and saga semantics.
- Read [../references/packages/package-conventions.md](../references/packages/package-conventions.md)
  when the work crosses SwiftPM package boundaries or resources.
- Use [../snippets/product-analytics.md](../snippets/product-analytics.md) for
  typed product analytics tree examples.
- Keep reducers in dedicated reducer files named by namespace path.
- Split models, DTOs, actions, effects, states, reducers, and helpers by
  namespace/type ownership instead of dumping entities into one file.
- Flows and sagas may read business state through dependencies, but must mutate
  state only by dispatching actions.
- Add focused Swift Testing coverage for reducer transitions, module
  registration, and flow/saga observable contracts when behavior changes.
