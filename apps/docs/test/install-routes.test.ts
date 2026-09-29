import { describe, expect, it, vi, beforeEach, afterEach } from 'vitest';
import { GET as getInstallSh } from '@/app/install.sh/route';
import { GET as getInstallPs1 } from '@/app/install.ps1/route';

describe('install script route handlers', () => {
  const originalFetch = globalThis.fetch;

  beforeEach(() => {
    vi.restoreAllMocks();
  });

  afterEach(() => {
    globalThis.fetch = originalFetch;
  });

  describe('GET /install.sh', () => {
    it('returns fetched script with correct headers when remote fetch succeeds', async () => {
      globalThis.fetch = vi.fn().mockResolvedValue({
        ok: true,
        text: async () => '#!/usr/bin/env sh\necho "installed"',
      } as unknown as Response);

      const response = await getInstallSh();
      expect(response.status).toBe(200);
      expect(response.headers.get('content-type')).toBe(
        'text/plain; charset=utf-8'
      );
      expect(response.headers.get('cache-control')).toContain('public');
      expect(response.headers.get('x-content-type-options')).toBe('nosniff');

      const text = await response.text();
      expect(text).toContain('#!/usr/bin/env sh');
    });

    it('falls back to local file when remote fetch fails', async () => {
      globalThis.fetch = vi.fn().mockRejectedValue(new Error('Network offline'));

      const response = await getInstallSh();
      // Should read local file in workspace
      expect(response.status).toBe(200);
      expect(response.headers.get('content-type')).toBe(
        'text/plain; charset=utf-8'
      );
      const text = await response.text();
      expect(text).toContain('BINARY_NAME="justui"');
    });
  });

  describe('GET /install.ps1', () => {
    it('returns fetched script with correct headers when remote fetch succeeds', async () => {
      globalThis.fetch = vi.fn().mockResolvedValue({
        ok: true,
        text: async () => '$BinaryName = "justui.exe"',
      } as unknown as Response);

      const response = await getInstallPs1();
      expect(response.status).toBe(200);
      expect(response.headers.get('content-type')).toBe(
        'text/plain; charset=utf-8'
      );
      expect(response.headers.get('cache-control')).toContain('public');
      expect(response.headers.get('x-content-type-options')).toBe('nosniff');

      const text = await response.text();
      expect(text).toContain('$BinaryName = "justui.exe"');
    });

    it('falls back to local file when remote fetch fails', async () => {
      globalThis.fetch = vi.fn().mockRejectedValue(new Error('Network offline'));

      const response = await getInstallPs1();
      expect(response.status).toBe(200);
      expect(response.headers.get('content-type')).toBe(
        'text/plain; charset=utf-8'
      );
      const text = await response.text();
      expect(text).toContain('$BinaryName = "justui.exe"');
    });
  });
});
