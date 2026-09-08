# Logout Cleanup Workflow

Use this workflow when implementing or reviewing logout/session reset.

- Read [../core/relux-core.md](../core/relux-core.md) for
  `Relux.Store.cleanup(exclusions:)` and state cleanup rules.
- Read [../swiftui/swiftui-relux.md](../swiftui/swiftui-relux.md)
  for the logout transition pattern.
- Use [../snippets/store-cleanup.md](../snippets/store-cleanup.md) for cleanup and
  logout ordering examples.
- Route to a small `logoutInProgress` surface before cleanup so disappearing
  product views release presentation-scoped `.task` work.
- Perform token/session teardown, service shutdown, store cleanup, and final
  routing in a saga or flow.
- Exclude only app-shell business states that must survive reset, such as
  routers, app configuration, feature flags, or network monitoring.
