import { source } from '@/lib/source';
import { createFromSource } from 'fumadocs-core/search/server';
import type { NextRequest } from 'next/server';

const { GET: fumadocsSearch } = createFromSource(source);

/**
 * Search API endpoint.
 *
 * Security notes:
 * - Responses are cached at the CDN edge (s-maxage=60) to reduce server load
 *   and mitigate naive DoS / scraping.
 * - For production traffic that requires strict rate limiting, add an
 *   edge middleware or use Vercel's built-in rate-limiting / Upstash Redis.
 * - The endpoint returns only pre-indexed, build-time content — no user
 *   input is persisted or reflected back without sanitisation by Fumadocs.
 */
export async function GET(request: NextRequest): Promise<Response> {
  const response = await fumadocsSearch(request);

  // Clone to make headers mutable (Response may be frozen).
  const mutable = new Response(response.body, response);

  // Cache at the CDN edge for 60 s; stale-while-revalidate for 5 min.
  // This significantly reduces the blast radius of a search-endpoint flood.
  mutable.headers.set(
    'Cache-Control',
    'public, s-maxage=60, stale-while-revalidate=300'
  );
  mutable.headers.set('X-Content-Type-Options', 'nosniff');

  return mutable;
}
