---
"docs": patch
---

docs(docs): migrate MDX Dart snippets to widgets.dart, material_ui, and Dart 3.14 idioms

- Replace legacy `package:flutter/material.dart` imports across EN and ID docs snippets with `package:flutter/widgets.dart` or `package:material_ui/material_ui.dart` (`show` where only icons/colors/divider are needed).
- Adopt Dart 3.10+ dot shorthands, explicit `.0` double literals, `MediaQuery.sizeOf(context)`, and `JustSpacing.insets(h:, v:)` in guide and token snippets.
- Add a Flutter < 3.50 `material.dart` note in EN and ID `installation.mdx`.
