# Phase 2: Core Components

> **Status:** 🟢 Complete — 15 components shipped
> **Sprint:** 5–10
> **Package:** `packages/core/`
> **Dependency:** Phase 1 (Token System + Theming Engine) 100% complete
> **Priority:** High — this is the primary product developers use.

---

## Overview

Phase 2 builds all reusable UI components on top of the Phase 1 foundation. Every component follows five principles:

1. **Token-driven** — no hardcoded values, everything references `packages/tokens/`
2. **Composable** — small primitives compose into complex components
3. **Accessible** — WCAG 2.1 AA minimum across all variants
4. **Customizable** — per-instance overrides via style class, global overrides via `ThemeExtension`
5. **Performant** — `const` constructors, `ValueNotifier` over `setState`, `RepaintBoundary` on animated components

---

## Component Architecture

Every component ships as a 4-file bundle:

| File                        | Purpose                               |
| --------------------------- | ------------------------------------- |
| `just_<name>.dart`          | Widget implementation                 |
| `just_<name>_style.dart`    | Per-instance style overrides          |
| `just_<name>_variants.dart` | Size/variant enums                    |
| `just_<name>_theme.dart`    | `ThemeExtension` for global overrides |

Internal shared utilities (not installed as standalone components):

| File                            | Purpose                                        |
| ------------------------------- | ---------------------------------------------- |
| `_shared_pressable.dart`        | Pressable wrapper with feedback and focus ring |
| `_shared_focus_indicator.dart`  | Accessible focus ring renderer                 |
| `_shared_progress_spinner.dart` | Loading spinner primitive                      |
| `_shared_tooltip_overlay.dart`  | Overlay positioning for tooltip                |

---

## Milestone I — Primitives ✅

| Component  | Files              | Notes                                                                        |
| ---------- | ------------------ | ---------------------------------------------------------------------------- |
| `button`   | 4 + `icon_button`  | Variants: primary, secondary, outline, ghost, destructive. Sizes: sm, md, lg |
| `input`    | 4                  | Text input with label, helper, error states                                  |
| `badge`    | 3                  | Status badge, no theme file needed                                           |
| `avatar`   | 4 + `avatar_group` | Image + initials fallback, group stacking                                    |
| `checkbox` | 3                  | Controlled + uncontrolled                                                    |
| `radio`    | 4 + `radio_group`  | Group with value management                                                  |
| `switch`   | 3                  | Toggle with animated thumb                                                   |

---

## Milestone II — Layout ✅

| Component     | Files | Notes                                      |
| ------------- | ----- | ------------------------------------------ |
| `card`        | 3     | Container with elevation, optional border  |
| `separator`   | 3     | Horizontal/vertical divider                |
| `skeleton`    | 3     | Loading placeholder with shimmer animation |
| `scroll-area` | 3     | Custom scrollbar styling                   |

---

## Milestone III — Navigation ✅

| Component    | Files               | Notes                                |
| ------------ | ------------------- | ------------------------------------ |
| `tabs`       | 5 + `tab_indicator` | Underline and pill variants          |
| `breadcrumb` | 4                   | With separator and overflow handling |
| `sidebar`    | 4                   | Collapsible, supports nested items   |
| `bottom-nav` | 4                   | Mobile bottom navigation bar         |

---

## Milestone IV — Overlay (Planned)

| Component | Status         | Notes                                             |
| --------- | -------------- | ------------------------------------------------- |
| `toast`   | ⚪ Not started | Stack-based notification system                   |
| `dialog`  | ⚪ Not started | Modal with backdrop                               |
| `sheet`   | ⚪ Not started | Bottom/side sheet                                 |
| `tooltip` | ⚪ Not started | Overlay positioning via `_shared_tooltip_overlay` |

---

## Neobrutalism Preset Rules

Components supporting the `neobrutalism` preset follow these constraints:

- Container border width: **2.5px** logical pixels
- Sidebar active-item accent border: **3.0px** (only this exception)
- Offset box shadows instead of elevation blurs
- High-contrast borders using `colors.border` semantic token
- No border-radius softening — sharp or minimal radius only

---

## Implementation Rules (All Components)

- `import 'package:flutter/material.dart'` always with a `show` clause listing only what's needed
- `Color.withValues(alpha:)` never `withOpacity`
- `RepaintBoundary` wrapping every animated component
- `ValueNotifier` + `ValueListenableBuilder` for local state, never `setState`
- Every public class and constructor must be `const`-compatible
- No external pub.dev dependencies in `packages/core/` (zero footprint)
