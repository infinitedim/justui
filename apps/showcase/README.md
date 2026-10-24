# showcase

The JustUI bridge: a Flutter web app (Wasm, multi-view embedded mode) that
renders the real `packages/core` components on the docs pages. The docs load
it from `/flutter/` and add one view per live part; the React parts in
`apps/docs/src/components/runner-kit/` stay as the SSR fallback.

- `lib/bridge/`: multi-view app, per-view host, the validated config and the
  JS interop (`initialData` in, `onReady(controller)` out).
- `lib/theme/`: the Ink and Paper theme, locked to the docs `--ip-*` tokens
  by `test/theme/ink_paper_drift_test.dart`.
- `lib/scenes/`: one demo per part, keyed by registry slug, mirroring the
  docs `KitPart`.
- `web/`: the bootstrap template (no `load()` call) and a development
  harness.

Run the harness (multi-view, preset/theme/locale controls):

```bash
fvm flutter run -d chrome --wasm
```

Build the bundle the docs serve (from `apps/docs`):

```bash
bun run flutter:build
```

Rules: `.agents/rules/flutter.md`, section "apps/showcase (bridge)".
