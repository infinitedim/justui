import { NextResponse } from 'next/server';
import { readFile } from 'node:fs/promises';
import path from 'node:path';

const INSTALL_SCRIPT_URL =
  'https://raw.githubusercontent.com/infinitedim/justui/main/packages/cli/install/install.sh';

export const dynamic = 'force-dynamic';

export async function GET(): Promise<NextResponse> {
  try {
    const res = await fetch(INSTALL_SCRIPT_URL, {
      signal: AbortSignal.timeout(5000),
    });

    if (res.ok) {
      const script = await res.text();
      return new NextResponse(script, {
        status: 200,
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400',
          'X-Content-Type-Options': 'nosniff',
        },
      });
    }
  } catch {
    // Network / offline error -- try local fallback
  }

  // Fallback 1: Local file in repository workspace
  try {
    const localPath = path.resolve(
      process.cwd(),
      '../../packages/cli/install/install.sh'
    );
    const content = await readFile(localPath, 'utf-8');
    return new NextResponse(content, {
      status: 200,
      headers: {
        'Content-Type': 'text/plain; charset=utf-8',
        'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400',
        'X-Content-Type-Options': 'nosniff',
      },
    });
  } catch {
    // Fallback 2: Graceful error script
    return new NextResponse(
      '#!/usr/bin/env sh\necho "Error: install script temporarily unavailable. Visit https://github.com/infinitedim/justui for manual installation."\nexit 1\n',
      {
        status: 502,
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Cache-Control': 'no-store',
          'X-Content-Type-Options': 'nosniff',
        },
      }
    );
  }
}
