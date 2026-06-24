// DEPRECATED: Replaced by proxy redirects in next.config.ts
// Next.js 16 no longer recommends middleware for i18n routing.
// Locale detection and routing is now handled via next.config.ts redirects
// and the [lang] dynamic route segment in the App Router.

import { NextResponse } from 'next/server';

export function proxy() {
  return NextResponse.next();
}
