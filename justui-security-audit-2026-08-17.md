# JustUI Security Audit — core & tokens (2026-08-17)

## Summary

JustUI's `packages/core/` and `packages/tokens/` have a genuinely small attack surface: zero external pub.dev dependencies, no network I/O, no persistence, no reflection/FFI/platform channels, no markup/HTML rendering, and no logging of any kind. The residual risk is concentrated entirely in **stateful lifecycle bugs**, not classic injection/auth/data-exposure vulnerabilities. Five verifiable findings were confirmed by direct source reading (cross-checked against the local Flutter SDK source where relevant): **1 High** (overlay controllers don't cascade-dispose active `OverlayEntry`s, causing indefinite leaks and stale-content persistence across navigation boundaries in Dialog/Sheet/Toast), **3 Medium** (a re-entrant dismiss race causing double-dispose crashes in Dialog/Sheet/Toast; unbounded `FocusNode` leaks per rebuild in the OTP input and searchable Select; loss of list virtualization in `JustTable` when `stickyHeader: false`), and **1 Low** (unbounded toast queue growth in `.queue` behavior mode). No injection, secret-exposure, ReDoS, or unsafe-dependency findings were identified — those categories were checked and are explicitly clean (see below).

## Findings

### [SEVERITY: High] Overlay Scope `dispose()` does not cascade to controller cleanup — Dialog, Sheet, and Toast all leak active `OverlayEntry`s

- **Location:**
  - `packages/core/lib/src/components/dialog/just_dialog.dart:466-471` (`_JustDialogScopeState.dispose()`)
  - `packages/core/lib/src/components/sheet/just_sheet.dart:553-558` (`_JustSheetScopeState.dispose()`)
  - `packages/core/lib/src/components/toast/just_toast.dart:638-643` (`_JustToastScopeState.dispose()`)
- **Category:** Section 2 — State & controller lifecycle (overlay system)
- **Skill used:** `/mobile-security-coder`, `/security-pen-testing`
- **Description:** `JustDialogScope`/`JustSheetScope`/`JustToastScope` are ordinary `StatefulWidget`s that bind a caller-supplied controller to a `TickerProvider`/`OverlayState`. Per the widgetbook usage pattern in `apps/preview/lib/usecases/dialog_usecases.dart`, these scopes are designed to be wrapped around an arbitrary subtree (e.g. a single screen/route), not necessarily the whole app. When the Scope widget unmounts (its host route is popped, or an ancestor rebuilds it away) **while a dialog/sheet/toast is still open**, `dispose()` only nulls out `_vsync`/`_overlayState` — it never calls `widget.controller.dismiss()`. The `OverlayEntry`s were inserted into an ancestor `Overlay` (typically the app/root `Navigator`'s overlay) obtained via `Overlay.of(context)`, which is **not** torn down along with the Scope. Nothing ever calls `.remove()`/`.dispose()` on those entries.
- **Evidence:**
  ```dart
  // just_dialog.dart:466-471 (identical pattern in just_sheet.dart / just_toast.dart)
  @override
  void dispose() {
    widget.controller._vsync = null;
    widget.controller._overlayState = null;
    super.dispose();
  }
  ```
  Compare with `JustDialogController.dispose()` itself (`just_dialog.dart:162-165`), which *would* clean up correctly if called — but nothing in the Scope's lifecycle ever calls it:
  ```dart
  @override
  void dispose() {
    dismiss();
  }
  ```
  The correct pattern already exists elsewhere in this exact codebase — `JustTooltip._JustTooltipState.dispose()` (`packages/core/lib/src/components/tooltip/just_tooltip.dart:84-91`) synchronously removes/disposes its own `OverlayEntry` on widget dispose:
  ```dart
  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _removeOverlayImmediate();   // <-- Dialog/Sheet/Toast Scope has no equivalent call
    _localAnimController.dispose();
    super.dispose();
  }
  ```
- **Impact:** Once a scope hosting an open dialog/sheet/toast unmounts, the `OverlayEntry` (plus its `AnimationController` and the entire widget/closure graph the caller passed as `content`/`action`/`onDismissed`) is retained **indefinitely** — it keeps building and painting on top of whatever screen is now active. In a B2B app that navigates between customer/tenant records (the kind of usage this library targets), this is not just a memory leak: it is a **stale-UI/context-confusion bug** — a dialog opened while viewing one record can keep rendering on top of an unrelated subsequently-navigated screen, and any sensitive data or callbacks captured in its `content` widget remain reachable far past the dialog's intended visible lifetime (directly relevant to the section 2 "retained closures over sensitive data" and section 5 data-exposure concerns).
- **Recommendation:** Have each Scope's `dispose()` call `widget.controller.dismiss()` (or a new synchronous force-clear method that immediately removes/disposes all active entries without waiting for the reverse animation) **before** nulling `_vsync`/`_overlayState`, mirroring `JustTooltip`'s pattern.
- **Verification status:** VERIFIED — read the full `show()`/`dismiss()`/`dispose()` chains in all three files plus the working counter-example in `just_tooltip.dart`.

---

### [SEVERITY: Medium] Re-entrant dismiss calls before the exit animation completes cause double-dispose crashes — Dialog, Sheet, and Toast

- **Location:**
  - `packages/core/lib/src/components/dialog/just_dialog.dart:134-152` (`_dismissDialog`), escape-key handler at `:384-388`
  - `packages/core/lib/src/components/sheet/just_sheet.dart:139-157` (`_dismissSheet`)
  - `packages/core/lib/src/components/toast/just_toast.dart:215-250` (`_dismissToast`)
- **Category:** Section 2 — race conditions in show/hide/dismiss sequencing
- **Skill used:** `/mobile-security-coder`, `/security-pen-testing`
- **Description:** Each `_dismiss*` function guards re-entrancy with `if (!_activeDialogs.contains(instance)) return;` at entry, but only removes the instance from that list **inside** the async `.reverse().then(...)` callback (a ~300ms animation by default). If the same instance is dismissed twice before that callback fires — e.g. the barrier is tapped and the Escape key is also pressed, or (most trivially) the **Escape key is simply held down**, which generates repeated `KeyDownEvent`s each independently invoking `widget.onDismiss(null)` (`just_dialog.dart:384-388`) — both calls pass the guard and each schedules its own cleanup.
- **Evidence:**
  ```dart
  // just_dialog.dart:134-152
  void _dismissDialog(_DialogInstance<dynamic> instance, dynamic result) {
    if (!_activeDialogs.contains(instance)) return;   // both re-entrant calls pass this
    instance.animationController.reverse().then((_) {
      instance.barrierEntry.remove();                  // called twice on the same entry
      instance.barrierEntry.dispose();                  // called twice on the same entry
      instance.contentEntry.remove();
      instance.contentEntry.dispose();
      if (instance.isLocalController) {
        instance.animationController.dispose();          // called twice on the same controller
      }
      _activeDialogs.remove(instance);                  // instance not removed until here
      ...
    });
  }
  ```
  Confirmed against the local Flutter SDK source (`~/fvm/versions/stable/packages/flutter/lib/src/widgets/overlay.dart`):
  ```dart
  void remove() {
    assert(_overlay != null, 'An OverlayEntry should be removed only once.');
    ...
  }
  void dispose() {
    assert(!_disposedByOwner);
    ...
  }
  ```
  `remove()`'s assertion is backed by a plain `!` null-check on `_overlay` immediately after, so a second `.remove()` call throws in **both debug and release** builds (`Null check operator used on a null value` in release). `AnimationController.dispose()` (via `ChangeNotifier.dispose()` in `change_notifier.dart:373-388`) asserts `debugAssertNotDisposed` — a debug-mode-only crash for that specific call, but still a real contract violation.
- **Impact:** A reproducible crash triggerable by ordinary keyboard interaction (holding Escape while a dialog is open) or by any UI automation/E2E harness that fires two close signals in quick succession. For unattended/kiosk-style B2B deployments this is an availability concern, not just a "flaky test."
- **Recommendation:** Make dismissal idempotent — remove the instance from `_activeDialogs`/`_activeSheets`/`_activeToasts` (or set a `_dismissing` flag on the instance) synchronously at the *start* of `_dismiss*`, before starting the reverse animation, so a second call for the same instance is a true no-op.
- **Verification status:** VERIFIED — reproduction path traced through the actual guard logic, and the double-dispose assertion behavior confirmed directly against the installed Flutter SDK source.

---

### [SEVERITY: Medium] `FocusNode` allocated and leaked on every rebuild — OTP input row and searchable Select dropdown

- **Location:**
  - `packages/core/lib/src/components/input/just_input.dart:965-968` (`_OtpInputRowState.build()`, `KeyboardListener.focusNode`)
  - `packages/core/lib/src/components/select/just_select.dart:543-544` (`_JustSelectState.build()`, `EditableText.focusNode` for the search box)
- **Category:** Section 6 — resource exhaustion (also touches Section 2, controller lifecycle)
- **Skill used:** `/security-auditor`, `/cc-skill-security-review`
- **Description:** Both locations construct `FocusNode()` directly as an inline widget-constructor argument inside `build()`, without storing a reference or ever calling `.dispose()`. Flutter's own documentation is explicit about ownership (`focus_manager.dart:384-388`): *"If another object owns the focus node, then it must call dispose() when the node is done being used."* Neither class's `dispose()` method (`just_input.dart:918-926`, `just_select.dart:124-130`) accounts for these nodes — they only dispose the nodes stored as State fields (`_focusNodes`, `_triggerFocusNode`, `_searchFocusNode`).
  For `JustSelect`, this is trivially reachable during normal use: `_searchController.addListener(_onSearchChanged)` (`just_select.dart:120`) calls `setState()` on **every keystroke** typed into the dropdown's search box, rebuilding `_JustSelectState` and allocating a fresh, never-disposed `FocusNode` each time.
- **Evidence:**
  ```dart
  // just_select.dart:540-544 — inside build(), re-executed on every keystroke via _onSearchChanged -> setState
  Expanded(
    child: EditableText(
      controller: _searchController,
      focusNode:
          FocusNode(), // internal dummy focus  <-- new instance every rebuild, never disposed
      ...
  ```
  ```dart
  // just_input.dart:965-968 — inside _OtpInputRowState.build()
  child: KeyboardListener(
    focusNode: FocusNode(
      skipTraversal: true,
    ), // Intermediate node to intercept backspace keys
  ```
  Confirmed against Flutter SDK source that neither `KeyboardListener`/`Focus` (`keyboard_listener.dart`) nor `EditableText` (`editable_text.dart:3443-3457`, which only calls `widget.focusNode.removeListener(...)`, never `.dispose()`) take ownership of an externally-supplied `FocusNode`.
- **Impact:** Unbounded `FocusNode` accumulation during ordinary interaction (typing in a searchable select, or entering/pasting an OTP code repeatedly). Each leaked node retains its `FocusAttachment`/manager registration indefinitely. Sustained or scripted interaction (UI test automation, kiosk-style repeated entry flows, or simply a user who backspaces/retypes a search query many times) accumulates nodes without bound over a long-running session — a resource-exhaustion pattern matching this audit's DoS framing, distinguished from a single-request exploit by requiring sustained interaction.
- **Recommendation:** Hoist these `FocusNode`s to `State` fields, created once in `initState()` and disposed in `dispose()` — exactly the pattern already used correctly for every other `FocusNode` in these same two classes.
- **Verification status:** VERIFIED — read the allocation site, the `setState` trigger path, the class's `dispose()` method, and cross-checked ownership semantics against the local Flutter SDK source (`focus_manager.dart`, `keyboard_listener.dart`, `editable_text.dart`).

---

### [SEVERITY: Medium] `JustTable` loses list virtualization when `stickyHeader: false`, allowing a large dataset to freeze the UI thread

- **Location:** `packages/core/lib/src/components/table/just_table.dart:353-358` (row `ListView.builder`), `:437-458` (layout branch selecting `Flexible` vs. unbounded `SingleChildScrollView`), `:91` (`stickyHeader` default)
- **Category:** Section 6 — resource exhaustion / missing virtualization on user-supplied data
- **Skill used:** `/security-auditor`, `/cc-skill-security-review`
- **Description:** Row content is always built via `ListView.builder(shrinkWrap: true, ...)` (`:353-358`). With the **default** `stickyHeader: true`, this list is wrapped in a bounded `Flexible` (`:441-446`), giving the sliver protocol a real viewport to lazily build against — this path is safe. But with the supported, non-default `stickyHeader: false`, the same `shrinkWrap: true` `ListView.builder` is instead wrapped directly in an **unbounded** `SingleChildScrollView` (`:448-458`), with no `itemExtent` supplied. A shrink-wrapped sliver list inside an unbounded-height ancestor has no way to determine its own intrinsic height without laying out every item, so Flutter must eagerly build and measure **all** rows synchronously, defeating the lazy-loading `ListView.builder` is meant to provide.
- **Evidence:**
  ```dart
  // just_table.dart:353-358
  bodyContent = ListView.builder(
    shrinkWrap: true,
    physics: widget.stickyHeader
        ? const ClampingScrollPhysics()
        : const NeverScrollableScrollPhysics(),
    itemCount: widget.rows.length,
    itemBuilder: (context, rowIndex) { ... }
  );
  ...
  // just_table.dart:447-458 (non-stickyHeader path — unbounded ancestor)
  } else {
    tableContent = SingleChildScrollView(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [headerRow, Container(...), bodyContent],
      ),
    );
  }
  ```
- **Impact:** A caller passing a large `rows` list (e.g. thousands of records from an unbounded/external data source) with `stickyHeader: false` forces a single-frame synchronous build of every row widget, freezing the UI thread proportionally to dataset size. This is a direct match for the audit's stated concern about "large/malicious dataset[s]" against list/grid components. The default configuration (`stickyHeader: true`) is not affected.
- **Recommendation:** Give `bodyContent` a bounded viewport regardless of `stickyHeader` (e.g., require/derive an explicit height for the non-sticky path too), or document prominently that `stickyHeader: false` should only be used with small, bounded datasets.
- **Verification status:** VERIFIED — read the actual layout branching code. The `shrinkWrap + unbounded ancestor forces eager building` behavior is standard, widely-documented Flutter `RenderShrinkWrappingViewport` behavior, not inferred/fabricated.

---

### [SEVERITY: Low] Unbounded pending-toast queue in `.queue` behavior mode

- **Location:** `packages/core/lib/src/components/toast/just_toast.dart:71` (`limit` field, only enforced for `.stacked`), `:85-90` (constructor), `:128-130` (`_queue.add(pending)`)
- **Category:** Section 6 — resource exhaustion
- **Skill used:** `/security-auditor`, `/cc-skill-security-review`
- **Description:** `limit` (default `3`) is only checked for the `.stacked` behavior (`just_toast.dart:135`: `if (limit != null && _activeToasts.length >= limit!)`). In `.queue` mode, `show()` unconditionally does `_queue.add(pending)` with no maximum size check.
- **Evidence:**
  ```dart
  // just_toast.dart:128-133
  if (behavior == .queue) {
    if (_activeToasts.isNotEmpty) {
      _queue.add(pending);              // no cap — grows without bound
    } else {
      _showToast(pending);
    }
  }
  ```
- **Impact:** A caller that invokes `.show()` at high frequency in `.queue` mode (e.g. naively mapping every message from a high-volume/untrusted event stream to a toast) grows `_queue` without bound, retaining every pending message/icon/action widget/callback in memory until drained one-by-one at `duration` intervals. Low severity because it requires the non-default `.queue` mode and caller-side misuse to manifest; it is a missing guardrail rather than an active defect.
- **Recommendation:** Apply `limit` (or a dedicated `queueLimit`) to `.queue` mode too, dropping or coalescing the oldest pending entries beyond the cap.
- **Verification status:** VERIFIED.

## Skills coverage log

| Skill | Section | What it flagged / confirmed |
|---|---|---|
| `/security-audit` | 0 (framing) | Generic web/API pentest workflow (SQLi, auth, Burp Suite, API fuzzing) — mostly inapplicable to a client-side Flutter UI library with no backend. Adapted scope to the SAST/hardening-adjacent phases only. |
| `/security-requirement-extraction` | 0 (framing) | Generic requirement-extraction templates (enterprise threat-model → requirement mapping). Used to derive JustUI-specific requirements: no I/O in the preset system, no telemetry/network calls given the copy-paste distribution model, controller/overlay lifecycle hygiene. |
| `/frontend-security-coder` | 1 | Entirely DOM/browser-oriented (innerHTML, CSP, cookies, localStorage, SRI). None of this surface exists in Flutter — confirmed no applicable finding. |
| `/web-security-testing` | 1 | OWASP web workflow (SQLi, XSS via DOM, CSRF, security headers) — no web/HTTP surface in scope. Confirmed no applicable finding. |
| `/mobile-security-coder` | 2 | Mostly WebView/keychain/certificate-pinning/biometric content, inapplicable (no WebView, no storage, no network in this scope). Its general "memory protection"/lifecycle lens was applied directly to the overlay controllers, contributing to Findings 1 and 2. |
| `/security-pen-testing` | 2 | Generic OWASP/API/infra pentest playbook, inapplicable as a literal checklist. Its "static analysis / systematic vulnerability discovery" methodology was applied manually to the overlay show/dismiss/dispose code paths, surfacing Findings 1 and 2. |
| `/security-scanning-security-hardening` | 3 | Full enterprise multi-agent hardening orchestrator (WAF, Vault, SIEM, IAM, OAuth2/OIDC). No infra/secrets/network surface in `packages/core`/`packages/tokens` for this to act on — confirmed not applicable. |
| `/frontend-mobile-security-xss-scan` | 3 | (Section 3 text requested `/frontend-mobile-security-scan`, which does not exist as an installed skill; the canonical skill list at the end of the prompt lists `/frontend-mobile-security-xss-scan`, which was invoked instead — see note below.) React/Vue/Angular innerHTML/`dangerouslySetInnerHTML`/`v-html` scanner; no such sinks exist in Dart/Flutter. Confirmed no applicable finding, consistent with direct grep showing no `TextSpan`/`RichText`/markdown/HTML rendering of user strings anywhere in scope. |
| `/security-scanning-security-dependencies` | 4 | Ecosystem-specific (Bandit/ESLint/Semgrep for Python/JS/Java/Go/Rust); no Dart/pub tooling. Methodology applied manually: confirmed `packages/core/pubspec.yaml` and `packages/tokens/pubspec.yaml` declare zero external pub.dev dependencies (only the `flutter` SDK, plus a local path dependency on `just_ui_tokens`). |
| `/security-scanning-security-sast` | 4 | Same multi-language SAST tool list (Bandit/Semgrep/CodeQL), no Dart support. Manually re-verified the `flutter/material.dart` import pattern and absence of `dart:ffi`/`dart:io`/`dart:mirrors`/`MethodChannel`/`dart:isolate` via direct grep — both confirmed clean. |
| `/senior-security` (section 5; `/security` requested but not an installed skill — see note below) | 5 | STRIDE threat-modeling router skill; referenced `scripts/secret_scanner.py` is not actually bundled in this environment (only `SKILL.md` present). Performed the equivalent manual secret-pattern grep across `packages/core`/`packages/tokens` — zero hardcoded secrets/keys/tokens found (one incidental `'secret123'` test fixture string in `just_input_test.dart`, not a real credential). |
| `/security-auditor` | 6 | General DevSecOps/audit skill; its "adversarial analysis of shared global state" lens was applied directly to `_activeDialogs`/`_activeSheets`/`_activeToasts`/`_queue`, contributing to Findings 1, 2, 4, and 5. |
| `/cc-skill-security-review` | 6 | Next.js/Supabase-oriented checklist (SQL, JWT, RLS, blockchain wallets) — inapplicable as a literal checklist. Manually verified the transferable "unbounded growth without a cap" pattern against `JustTable`'s virtualization and `JustToastController`'s queue, producing Findings 4 and 5. |
| `/security-compliance-compliance-check` | 7 | GDPR/HIPAA/SOC2/PCI-DSS full-system compliance workflow. No standalone compliance-relevant gap: this library has no persistence, logging, or transmission of data. Finding 1's indefinite retention of caller-supplied dialog/sheet/toast content has a minor data-minimization angle, noted as an impact detail on that finding rather than a separate top-level compliance finding. |

**Note on skill-name mismatches:** two skills named in the per-section instructions do not match the "Skill reference" canonical list (and one, oddly, isn't in the canonical list either but does exist as an installed skill):
- Section 3 asked for `/frontend-mobile-security-scan`; the canonical list has `/frontend-mobile-security-xss-scan` instead. Invoked the canonical one.
- Section 5 asked for `/security`; attempting to load it returned `Skill "security" not found` (confirmed via the tool's own error, which lists all installed skills — no plain `security` skill exists, and none of the enumerated skills is a closer match than the already-required `/senior-security`). Proceeded with `/senior-security` only for that section, noted honestly rather than fabricating output for a nonexistent skill.
- Section 6 asked for `/cc-skill-security-review`, which is **not** in the prompt's canonical "Skill reference" list at the end, but **is** actually an installed, loadable skill in this environment — invoked successfully.

## Non-issues explicitly checked

- **Injection/rich-text rendering (Section 1):** No `TextSpan`/`RichText`/markdown/HTML-lite parser renders user-supplied strings as interpretable markup anywhere in `packages/core` or `packages/tokens`; Flutter's `Text`/`EditableText` render strings literally. Only one `RegExp` exists in the entire scope (`just_input.dart:935`, `RegExp(r'\D')` — a single negated-digit character class, not ReDoS-prone). No `launchUrl`/`Uri.parse`-based navigation, no WebView, no `dart:html`/`package:web`.
- **Password/obscure-text handling (`JustInput.password`):** Properly threads `obscureText` through to the native text field; no logging or persistence of entered values beyond the standard `TextEditingController`.
- **Preset/token system I/O (Section 3):** `JustPresetTokens` (`packages/core/lib/src/theme/preset_tokens.dart`) and its two implementations (`DefaultPresetTokens`, `NeobrutalismPresetTokens`) are pure, side-effect-free computation classes — no `Platform.environment`, no file reads, no network calls, no deserialization (`jsonDecode`/`fromJson`), no `SharedPreferences`/`localStorage`-equivalent persistence anywhere in scope. Preset switching is a plain enum-driven `JustThemeData` field, not a dynamically-loaded/deserialized object.
- **`flutter/material.dart` import discipline (Section 4):** Re-verified — only `packages/core/lib/src/theme/theme_data_material.dart` imports `package:flutter/material.dart` without a `show` clause. All other 45 files that touch Material import it with a narrow `show` clause (`Theme`, `ThemeExtension`, `ThemeMode`, or `Icons, Theme`).
- **Reflection/FFI/platform channels (Section 4):** Zero matches for `dart:ffi`, `dart:io`, `dart:mirrors`, `Platform.`, `MethodChannel`, `dart:isolate` in `packages/core/lib` or `packages/tokens/lib`.
- **Zero-dependency footprint (Section 4):** `packages/core/pubspec.yaml` and `packages/tokens/pubspec.yaml` depend only on the `flutter` SDK (plus `just_ui_core` → `just_ui_tokens` via a local path dependency). The root monorepo `pubspec.yaml`'s `crypto`/`path` dependencies are used exclusively by `tools/apply_changesets.dart` and `tools/generate_checksums.dart` (release tooling, outside the audited packages) — never imported by `packages/core/lib` or `packages/tokens/lib`.
- **Logging/`toString()` exposure (Section 5):** Zero `debugPrint`/`print`/`log()` calls anywhere in `packages/core` or `packages/tokens`. Exactly one `toString()` override in the entire scope (`JustRangeValues` in `just_slider.dart:30`), exposing only two numeric range values — benign.
- **Secrets (Section 5):** No hardcoded API keys, tokens, passwords, or private-key material anywhere in the audited packages.
- **`JustSelect` dropdown virtualization:** Uses `ListView.builder` inside a bounded `Expanded`/fixed-height dropdown container — correctly virtualized, unlike the `JustTable` non-default path.
- **Tooltip overlay lifecycle:** Both tooltip implementations checked. `_shared_tooltip_overlay.dart` uses the framework-managed `OverlayPortal` API (automatic lifecycle, no manual dispose needed). `just_tooltip.dart` uses manual `OverlayEntry` management but correctly and synchronously disposes it in `State.dispose()` — this is the *correct* pattern that Dialog/Sheet/Toast should follow (see Finding 1).
- **`AnimationController`/shared-component lifecycle sweep:** Every other `AnimationController` and `FocusNode` allocation site across all 26 components (`badge`, `sidebar`, `tabs`, `switch`, `checkbox`, `radio`, `accordion`, `progress`, `skeleton`, `_shared_pressable`, `_shared_focus_indicator`, `_shared_progress_spinner`) was checked and creates its controller/node once in `initState()` (or via a correctly-guarded lazy `??=` pattern with a matching `dispose()`), and disposes it correctly — the two locations in Finding 3 are deviations from an otherwise-consistent pattern, not systemic.
- **`isLocalController` ownership flag (Dialog/Sheet):** Correctly distinguishes caller-supplied `AnimationController`s (never disposed by JustUI) from internally-created ones (disposed on dismiss) — confirmed correct, not a double-free-of-caller-owned-object risk.
- **Public barrel exports:** `packages/core/lib/just_ui_core.dart` exposes only the theming kernel (theme data/provider/aspects/preset-tokens, overlay controller/scope) plus the re-exported tokens barrel — no component files or private shared-component barrels are leaked through the public API, consistent with the documented barrel-isolation policy.
- **Baseline cross-reference — "zero `isNeobrutalism` boolean checks":** Confirmed no literal `isNeobrutalism` boolean property/check exists anywhere in scope. Noted (but not flagged as a security finding, since it is a code-organization observation with zero security impact) that `packages/core/lib/src/theme/theme_data.dart` contains several `preset == .neobrutalism` **enum** comparisons (lines 669, 679, 696, 748, 765, 799, 858) as convenience helpers on `JustThemeData` itself, alongside — not instead of — the clean `JustPresetTokens` abstraction. This is a duplication/maintainability note, not a regression of the specific "boolean flag" pattern the baseline addressed, and is out of scope for a security audit.

## Out-of-scope observations

- **No dedicated tests exist for the overlay system.** `packages/core/test/` has no test files for Dialog, Sheet, Toast, Select, Slider, Accordion, Progress, Tooltip, or Table (only `theme_test.dart` and a `components/` folder covering ~14 of the 26 components). This is consistent with Findings 1–4 having gone unnoticed; recommend adding lifecycle/widget tests for the overlay controllers as a follow-up, though test coverage itself is out of this audit's scope.
- **`packages/cli/` (Rust)** was not audited per instructions. It is the component that actually performs the `_shared_` → `just_` file-copy/rename and import-rewriting described in this repo's shared-component conventions; a future pass should verify it doesn't let a crafted `justui.config.yaml`/registry entry write outside the target project directory (path traversal) — noted only because it's adjacent to the token/preset system, not verified here.
- **`apps/preview`, `apps/showcase`, `apps/docs`** were not audited. `apps/preview` was read incidentally (for real-world `JustDialogScope`/`JustSheetScope`/`JustToastScope` usage patterns, to determine whether Finding 1's scenario is realistic) — it confirms these scopes are used wrapped around sub-trees via widgetbook use-cases, supporting Finding 1's realism, but no findings were raised against `apps/` code itself.
- **Root-level `pubspec.yaml`** declares `crypto`/`path` for repo build tooling (`tools/apply_changesets.dart`, `tools/generate_checksums.dart`). These are unaudited (out of scope) but are worth a quick dependency-vulnerability check in a future CLI/tooling-focused pass since they are real external dependencies, just not ones that ship inside `packages/core`/`packages/tokens`.
