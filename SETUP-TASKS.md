# Setup tasks that the new rules assume

The rules describe the target state. These changes make the repo match it.
Each item is one task; most fit one commit. Items marked (red zone) need a
plan first under the new rules.

## Install the rules

1. Replace root `AGENTS.md` with the new one. Add `GEMINI.md`,
   `.agents/rules/*.md` and `.agents/skills/justui-design/SKILL.md`.
2. Remove `.agents/skills/taste-skill` (replaced by `justui-design`) and
   `.agents/skills/senior-architect` (already marked for removal).
3. `.gitignore`: add `.agents/tmp/`.
4. Move `justui-audit.md` out of the repo into `.agents/tmp/` (git-ignored).
   Note: deleting it from HEAD does not remove it from git history. Rewriting
   history needs a force-push, which the rules forbid for the agent; decide
   yourself whether it is worth it.
5. Fix `CONTRIBUTING.md` step 4 (barrel export) so the warning in `AGENTS.md`
   can be dropped later.

## Docs site config (apps/docs)

6. `eslint.config.js`: `@typescript-eslint/no-explicit-any` from `warn` to
   `error` (current usage is 0, so this should pass as is).
7. `tsconfig.json`: add `"noUncheckedIndexedAccess": true`, then fix the
   errors it reports (expect a fair number in parsers and data maps).
8. `next.config.ts`: `reactCompiler: true`. Add the compiler lint rules
   (check whether the installed `eslint-plugin-react-hooks` v7 config already
   ships them) and run the full test and e2e suite.
9. Remove `react-icons`. Add a local GitHub mark component under
   `src/components/atoms/`, use it in `organisms/footer/footer.tsx` and
   `molecules/github-pill/github-pill.tsx`.
10. Migrate Indonesian copy from "Anda" to "kamu": `content/docs/id/**`
    (137 occurrences) and the ID strings in `src/lib/*-translations.ts`.
11. Add Playwright visual snapshot tests (`toHaveScreenshot`) for landing,
    catalog, one docs page and Studio, each in default/neobrutalism x
    light/dark.
12. Add a test that validates every Dart snippet in MDX and in
    `code-generators.ts` against `packages/core` (class, constructor and
    parameter names; import paths).
13. Give every page `generateMetadata` (unique title, description,
    `alternates.languages`, Open Graph).

## CI and tooling (red zone)

14. CI: run `bun run generate:components -- --check` in `nextjs-ci`.
15. CI: align the Bun pin with the `bun.lock` format (audit #62).
16. `tools/generate_checksums.dart --dry-run`: exit non-zero on drift so the
    CI step catches it (audit #63).

## MCP setup (do these yourself in Antigravity, via "Open MCP Config")

The agent may not change MCP config, so these are manual.

20. Turn off `cloudrun`, `android-management-api` and `gopls-mcp-server`
    while you work on JustUI. The toggles are probably global, so turn
    `cloudrun` back on when you work on the portfolio backend.
21. Playwright args: add isolation, the origin allowlist and the output dir.
    `--allowed-origins` is semicolon-separated and is not a security
    boundary (redirects are not checked); it only keeps the agent on-site.

    ```json
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--isolated",
        "--allowed-origins", "http://localhost:3000;https://justui.vercel.app",
        "--output-dir", ".agents/tmp/screenshots"
      ]
    }
    ```

    Replace `https://justui.vercel.app` if your production domain differs
    (it is the fallback for `NEXT_PUBLIC_SITE_URL` in `src/lib/site.ts`).
    If the config is global, add the dev-server origins of your other
    projects too, or they will be blocked.
22. Disable `browser_run_code_unsafe` in the Playwright tool list (the panel
    shows per-server tool counts, so per-tool toggles are likely; if not,
    the rule in `mcp.md` is the only guard).
23. dart-mcp-server: enable `run_tests`, `launch_app`, `stop_app`,
    `get_app_logs`, `list_devices`. Keep `dart_fix` off.
24. Add a library docs server (Context7). Check its README for the current
    package name and config before adding it. An API key is optional for
    light use.
25. mem0: if your gateway lets you, restrict this workspace to `app_id`
    `justui` and block `invoke` / `request_access` at the gateway level, so
    the rule is not the only guard.

## Larger projects (plan separately)

26. Flutter web embed for live component demos, replacing the React mocks in
    `src/components/organisms/simulators/`. Needs a CSP change
    (`frame-src`/`wasm`), bundle budget, loading state and fallback.
27. CSP nonces so `'unsafe-inline'` can leave `script-src` (theme and preset
    bootstrap scripts).
28. Release checksums and pinned install script URLs (supply chain items in
    `security.md`).
