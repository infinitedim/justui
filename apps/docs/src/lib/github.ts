import { z } from 'zod';
import { env } from '@/lib/env';

const GITHUB_REPO = 'infinitedim/justui';

const githubRepoSchema = z.object({
  stargazers_count: z.number().optional(),
});

export async function fetchStarCount(): Promise<number | null> {
  try {
    const headers: Record<string, string> = {
      Accept: 'application/vnd.github+json',
      // Required by GitHub API guidelines for proper attribution and
      // higher rate limits (60 req/hr -> 5000 req/hr with auth).
      'User-Agent': 'JustUI-Docs/1.0',
    };

    const token = env.GITHUB_TOKEN;
    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }

    const response = await fetch(
      `https://api.github.com/repos/${GITHUB_REPO}`,
      {
        next: { revalidate: 3600 },
        headers,
      }
    );

    if (!response.ok) return null;

    const rawJson: unknown = await response.json();
    const parsed = githubRepoSchema.safeParse(rawJson);
    if (!parsed.success || typeof parsed.data.stargazers_count !== 'number') {
      return null;
    }
    return parsed.data.stargazers_count;
  } catch {
    return null;
  }
}

export const githubUrl = `https://github.com/${GITHUB_REPO}`;
