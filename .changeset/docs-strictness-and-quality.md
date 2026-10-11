---
"docs": patch
---

feat(docs): overhaul typescript strictness, type assertions, and quality pipeline

- Add strict TypeScript flags (noUncheckedIndexedAccess, noFallthroughCasesInSwitch, verbatimModuleSyntax).
- Upgrade ESLint to recommended-type-checked without type assertions or non-null assertions in production code.
- Add src/lib/env.ts with Zod schema validation and src/lib/result.ts Result type.
- Add bundle size budget check script and CI integration.
- Migrate Indonesian documentation copy from Anda to kamu.
- Add Playwright accessibility audit suite and visual snapshot configurations.
- Add MDX Dart snippet validation tool and test suite.
