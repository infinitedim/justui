import { source } from '@/lib/source';
import { createFromSource } from 'fumadocs-core/search/server';
import type { NextRequest } from 'next/server';
import { z } from 'zod';

const { GET: fumadocsSearch } = createFromSource(source);

export const dynamic = 'force-dynamic';

const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX_REQUESTS = 60;
const MAX_RATE_LIMIT_STORE_ENTRIES = 5_000;
const MAX_QUERY_LENGTH = 400;

const searchParamsSchema = z.object({
  query: z
    .string()
    .max(MAX_QUERY_LENGTH, 'Query length exceeds 400 characters')
    .optional(),
  limit: z.coerce.number().int().positive().max(100).optional(),
  locale: z.string().max(20).optional(),
  tag: z.string().max(100).optional(),
});

interface RateLimitRecord {
  count: number;
  resetAt: number;
}

const rateLimitStore = new Map<string, RateLimitRecord>();

/**
 * Resets the in-memory rate limit store.
 * For testing use only.
 */
export function _resetRateLimitsForTesting(): void {
  rateLimitStore.clear();
}

/**
 * Extracts client IP from trusted reverse proxy headers or direct socket info.
 * Prioritizes x-real-ip, then x-forwarded-for, capped at 64 characters.
 */
function getClientIp(request: Request | NextRequest): string {
  const directIp =
    'ip' in request && typeof request.ip === 'string' ? request.ip : undefined;
  if (directIp && directIp.trim().length > 0) {
    return directIp.trim().slice(0, 64);
  }

  const realIp = request.headers.get('x-real-ip');
  if (realIp && realIp.trim().length > 0) {
    return realIp.trim().slice(0, 64);
  }

  const forwarded = request.headers.get('x-forwarded-for');
  if (forwarded) {
    const first = forwarded.split(',')[0];
    if (first && first.trim().length > 0) {
      return first.trim().slice(0, 64);
    }
  }

  return '127.0.0.1';
}

/**
 * Checks in-memory rate limit for a client IP with strictly capped memory usage.
 */
function checkRateLimit(
  ip: string,
  now: number = Date.now()
): { allowed: boolean; retryAfterSeconds: number } {
  if (rateLimitStore.size >= MAX_RATE_LIMIT_STORE_ENTRIES) {
    for (const [key, value] of rateLimitStore.entries()) {
      if (now >= value.resetAt) {
        rateLimitStore.delete(key);
      }
    }
    // If still at capacity after pruning expired items, evict oldest entry
    if (rateLimitStore.size >= MAX_RATE_LIMIT_STORE_ENTRIES) {
      const oldestKey = rateLimitStore.keys().next().value;
      if (oldestKey !== undefined) {
        rateLimitStore.delete(oldestKey);
      }
    }
  }

  const existing = rateLimitStore.get(ip);
  if (!existing || now >= existing.resetAt) {
    rateLimitStore.set(ip, {
      count: 1,
      resetAt: now + RATE_LIMIT_WINDOW_MS,
    });
    return { allowed: true, retryAfterSeconds: 0 };
  }

  if (existing.count >= RATE_LIMIT_MAX_REQUESTS) {
    const retryAfterSeconds = Math.max(
      1,
      Math.ceil((existing.resetAt - now) / 1000)
    );
    return { allowed: false, retryAfterSeconds };
  }

  existing.count += 1;
  return { allowed: true, retryAfterSeconds: 0 };
}

/**
 * Search API endpoint.
 *
 * Security notes:
 * - Query parameters parsed and validated with Zod.
 * - In-memory rate limiting per client IP (60 req / 60 s) with 429 Retry-After.
 * - Memory usage strictly bounded with LRU eviction on store capacity.
 * - Strict query length limit capped at 400 characters (returns 400 on breach).
 * - Edge CDN cache headers (s-maxage=60) preserved to mitigate DoS.
 * - Endpoint serves only pre-indexed build-time content.
 */
export async function GET(request: NextRequest): Promise<Response> {
  const ip = getClientIp(request);
  const rateLimit = checkRateLimit(ip);

  if (!rateLimit.allowed) {
    return Response.json(
      { error: 'Too many requests' },
      {
        status: 429,
        headers: {
          'Content-Type': 'application/json',
          'Retry-After': String(rateLimit.retryAfterSeconds),
        },
      }
    );
  }

  const url = new URL(request.url);
  const rawParams = Object.fromEntries(url.searchParams.entries());
  const parsed = searchParamsSchema.safeParse(rawParams);

  if (!parsed.success) {
    const message =
      parsed.error.issues[0]?.message ?? 'Invalid query parameters';
    return Response.json(
      { error: message },
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );
  }

  const response = await fumadocsSearch(request);

  // Clone to make headers mutable (Response may be frozen).
  const mutable = new Response(response.body, response);

  // Cache at the CDN edge for 60 s; stale-while-revalidate for 5 min.
  mutable.headers.set(
    'Cache-Control',
    'public, s-maxage=60, stale-while-revalidate=300'
  );
  mutable.headers.set('Content-Type', 'application/json');
  mutable.headers.set('X-Content-Type-Options', 'nosniff');

  return mutable;
}
