---
"docs": minor
---

feat(docs): render live Flutter components through the showcase bridge

- The 404 page now shows the real `JustButton` from `packages/core`, built by `apps/showcase` (Flutter web, Wasm, multi-view) and mounted over its React part. Browsers without Blink + WasmGC, no JavaScript and a missing bundle keep the React part.
- Live parts follow the visitor's preset, theme (including the page curl) and locale, keep keyboard order and let the page scroll on touch screens.
- The CSP allows `worker-src 'self' blob:` for multi-threaded skwasm.
- Vercel builds the bundle (`scripts/vercel-build.sh`, cached by input hash) and CI gets a `showcase-web` job with golden tests and a size budget.
