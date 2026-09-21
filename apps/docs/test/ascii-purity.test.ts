import { describe, expect, it } from 'vitest';
import * as fs from 'node:fs';
import * as path from 'node:path';

function getFilesRecursively(
  dir: string,
  extensions: Array<string>
): Array<string> {
  const results: Array<string> = [];
  if (!fs.existsSync(dir)) return results;

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (
        entry.name === 'node_modules' ||
        entry.name === '.next' ||
        entry.name === 'dist' ||
        entry.name === '.git'
      ) {
        continue;
      }
      results.push(...getFilesRecursively(fullPath, extensions));
    } else if (entry.isFile()) {
      const ext = path.extname(entry.name);
      if (extensions.includes(ext)) {
        results.push(fullPath);
      }
    }
  }
  return results;
}

const rootDir = path.resolve(__dirname, '..');
const srcDir = path.join(rootDir, 'src');
const contentDir = path.join(rootDir, 'content');
const testDir = path.join(rootDir, 'test');

const allFiles = [
  ...getFilesRecursively(srcDir, ['.ts', '.tsx', '.css']),
  ...getFilesRecursively(contentDir, ['.mdx']),
  ...getFilesRecursively(testDir, ['.ts', '.tsx']),
].map((p) => path.relative(rootDir, p));

describe('Strict ASCII Purity Check', () => {
  it('discovers files across src, content, and test directories', () => {
    expect(allFiles.length).toBeGreaterThan(100);
  });

  it.each(allFiles)('file %s contains 100% pure ASCII bytes', (relPath) => {
    const fullPath = path.resolve(rootDir, relPath);
    expect(fs.existsSync(fullPath)).toBe(true);

    const buf = fs.readFileSync(fullPath);
    for (let i = 0; i < buf.length; i++) {
      const byte = buf[i];
      if (byte > 127) {
        throw new Error(
          `Non-ASCII byte ${byte} (0x${byte.toString(16)}) found at index ${i} in ${relPath}`
        );
      }
    }
  });
});
