const GITHUB_REPO = 'infinitedim/justui';

interface GitHubRepoResponse {
  stargazers_count?: number;
}

export async function fetchStarCount(): Promise<number | null> {
  try {
    const headers: Record<string, string> = {
      Accept: 'application/vnd.github+json',
      // Required by GitHub API guidelines for proper attribution and
      // higher rate limits (60 req/hr → 5000 req/hr with auth).
      'User-Agent': 'JustUI-Docs/1.0',
    };

    const token = process.env.GITHUB_TOKEN;
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

    const data = (await response.json()) as GitHubRepoResponse;
    return typeof data.stargazers_count === 'number'
      ? data.stargazers_count
      : null;
  } catch {
    return null;
  }
}

export const githubUrl = `https://github.com/${GITHUB_REPO}`;
