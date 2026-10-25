---
"docs": minor
---

feat(docs): render live Flutter components through the showcase bridge

- The 404 page now shows real `packages/core` components, built by `apps/showcase` (Flutter web, Wasm, multi-view) and mounted over their React parts. 17 of the 33 parts render live; the other 16 stay React until core fixes the gaps listed in `apps/showcase/lib/scenes/scene_registry.dart`. Browsers without Blink + WasmGC, no JavaScript and a missing bundle keep the React parts.
- Tab enters each live part at its first control, and parts with no control are not Tab stops.
- Live parts follow the visitor's preset, theme (including the page curl) and locale, keep keyboard order and let the page scroll on touch screens.
- The CSP allows `worker-src 'self' blob:` for multi-threaded skwasm.
- Vercel builds the bundle (`scripts/vercel-build.sh`, cached by input hash) and CI gets a `showcase-web` job with golden tests and a size budget.
