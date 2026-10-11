import path from 'node:path';
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  resolve: {
    tsconfigPaths: true,
    alias: {
      '@': path.resolve(import.meta.dirname, './src'),
      'collections/server': path.resolve(
        import.meta.dirname,
        './test/mocks/collections-server.ts'
      ),
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['test/setup.ts'],
    exclude: ['**/node_modules/**', '**/e2e/**', '**/.next/**'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/app/api/**', 'src/app/globals.css'],
      thresholds: {
        'src/lib/**': {
          lines: 80,
          functions: 80,
          branches: 65,
          statements: 80,
        },
      },
    },
  },
});
