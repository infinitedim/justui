import { readFileSync, readdirSync, statSync } from 'node:fs';
import path from 'node:path';
import { describe, expect, it } from 'vitest';
import { GENERATED_COMPONENTS } from '@/lib/components.generated';

function findMdxFiles(dir: string): Array<string> {
  const results: Array<string> = [];
  const entries = readdirSync(dir);
  for (const entry of entries) {
    const fullPath = path.join(dir, entry);
    const stat = statSync(fullPath);
    if (stat.isDirectory()) {
      results.push(...findMdxFiles(fullPath));
    } else if (entry.endsWith('.mdx')) {
      results.push(fullPath);
    }
  }
  return results;
}

function extractDartSnippets(mdxContent: string): Array<string> {
  const snippets: Array<string> = [];
  const regex = /```dart\s*([\s\S]*?)```/g;
  let match: RegExpExecArray | null = regex.exec(mdxContent);
  while (match !== null) {
    if (match[1]) {
      snippets.push(match[1]);
    }
    match = regex.exec(mdxContent);
  }
  return snippets;
}

const FOUNDATION_OR_TOKEN_PREFIXES = [
  'JustUI',
  'JustTheme',
  'JustColor',
  'JustMotion',
  'JustRadius',
  'JustShadow',
  'JustSpacing',
  'JustTypo',
  'JustFluidTypo',
  'JustBreakpoints',
  'JustCurves',
  'JustDuration',
  'JustGap',
  'JustOverlay',
  'JustRangeValues',
  'JustCalendarView',
  'JustFormInput',
];

describe('MDX and Generated Dart Snippets Validation', () => {
  const mdxDir = path.resolve(import.meta.dirname, '../content/docs');
  const mdxFiles = findMdxFiles(mdxDir);
  const knownComponentNames = new Set(GENERATED_COMPONENTS.map((c) => c.name));

  it('finds MDX files in content/docs', () => {
    expect(mdxFiles.length).toBeGreaterThan(0);
  });

  it('ensures no Dart snippets import banned packages', () => {
    for (const filePath of mdxFiles) {
      const content = readFileSync(filePath, 'utf-8');
      const snippets = extractDartSnippets(content);
      const relative = path.relative(mdxDir, filePath);

      for (const snippet of snippets) {
        expect(
          snippet,
          `File ${relative} contains forbidden package:just_ui_core import`
        ).not.toContain('package:just_ui_core');

        expect(
          snippet,
          `File ${relative} contains forbidden package:just_ui_tokens import`
        ).not.toContain('package:just_ui_tokens');
      }
    }
  });

  it('ensures all Just* components used in snippets exist in registry or relate to them', () => {
    const justComponentRegex = /\bJust[A-Z][a-zA-Z0-9]+\b/g;

    for (const filePath of mdxFiles) {
      const content = readFileSync(filePath, 'utf-8');
      const snippets = extractDartSnippets(content);
      const relative = path.relative(mdxDir, filePath);

      for (const snippet of snippets) {
        let match: RegExpExecArray | null = justComponentRegex.exec(snippet);
        while (match !== null) {
          const compName = match[0];
          const isFoundation = FOUNDATION_OR_TOKEN_PREFIXES.some((prefix) =>
            compName.startsWith(prefix)
          );

          if (!isFoundation) {
            const matchesRegistered =
              knownComponentNames.has(compName) ||
              compName.startsWith('JustScroll') ||
              compName.startsWith('JustTab') ||
              compName.startsWith('JustDate') ||
              Array.from(knownComponentNames).some((name) =>
                compName.startsWith(name)
              );

            expect(
              matchesRegistered,
              `Component ${compName} in ${relative} must relate to a registered component in GENERATED_COMPONENTS`
            ).toBe(true);
          }
          match = justComponentRegex.exec(snippet);
        }
      }
    }
  });
});
