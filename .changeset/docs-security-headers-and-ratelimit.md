---
"docs": patch
---

feat(docs): lock security headers and CSP, add security.txt, and rate-limit search route

- Add RFC 9116 `security.txt` at `apps/docs/public/.well-known/security.txt`.
- Add Vitest security headers, CSP baseline, and security.txt expiration guard tests.
- Add query length limit (400 characters) and in-memory rate limiter with Retry-After header to `/api/search`.
