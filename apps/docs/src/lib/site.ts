import { env } from '@/lib/env';

/**
 * The deployed docs site. Install scripts, share links, metadata, robots and
 * the sitemap all derive from this one value; override it per deployment
 * with NEXT_PUBLIC_SITE_URL.
 */
export const SITE_URL = env.NEXT_PUBLIC_SITE_URL ?? 'https://justui.vercel.app';
