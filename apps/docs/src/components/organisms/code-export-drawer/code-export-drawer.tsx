'use client';

import { useId, useMemo, useState } from 'react';
import { DynamicCodeBlock } from 'fumadocs-ui/components/dynamic-codeblock';
import { cn } from '@/lib/cn';
import { useThemeStudio } from '@/lib/theme-studio-context';
import { getStudioDictionary } from '@/lib/theme-studio-translations';
import { useRovingTabs } from '@/lib/use-roving-tabs';
import { CopyButton } from '@/components/molecules/copy-button';
import { CodeBlockHeader } from '@/components/molecules/code-block-header';
import { generateYaml, generateDart, generateCli } from './code-generators';
import type {
  CodeExportDrawerProps,
  ExportTab,
} from './code-export-drawer.types';

export function CodeExportDrawer({
  lang = 'en',
  className,
  defaultTab = 'yaml',
}: CodeExportDrawerProps) {
  const t = getStudioDictionary(lang);
  const studio = useThemeStudio();
  const [tab, setTab] = useState<ExportTab>(defaultTab);

  const yamlCode = useMemo(() => {
    return generateYaml(studio, studio.shareUrl);
  }, [studio]);

  const dartCode = useMemo(() => {
    return generateDart(studio);
  }, [studio]);

  const cliCode = useMemo(() => {
    return generateCli(studio);
  }, [studio]);

  const currentConfig = useMemo(() => {
    switch (tab) {
      case 'yaml':
        return {
          code: yamlCode,
          language: 'yaml' as const,
          filename: 'justui.config.yaml',
          label: t.tabYaml,
        };
      case 'dart':
        return {
          code: dartCode,
          language: 'dart' as const,
          filename: 'theme.dart',
          label: t.tabDart,
        };
      case 'cli':
        return {
          code: cliCode,
          language: 'bash' as const,
          filename: 'Terminal',
          label: t.tabCli,
        };
    }
  }, [tab, yamlCode, dartCode, cliCode, t]);

  const tabs: Array<{ id: ExportTab; label: string }> = [
    { id: 'yaml', label: t.tabYaml },
    { id: 'dart', label: t.tabDart },
    { id: 'cli', label: t.tabCli },
  ];
  const tabIds = useMemo<ExportTab[]>(() => ['yaml', 'dart', 'cli'], []);
  const { registerTab, onKeyDown } = useRovingTabs(tabIds, tab, setTab);
  const idPrefix = useId();
  const tabId = (id: ExportTab) => `${idPrefix}-tab-${id}`;
  const panelId = `${idPrefix}-panel`;

  return (
    <div
      className={cn(
        'border-border bg-card flex flex-col overflow-hidden rounded-(--just-radius-lg) border shadow-sm',
        className
      )}
      data-testid="code-export-drawer"
    >
      {/* Tab Navigation Header */}
      <div className="border-border bg-muted/20 flex flex-wrap items-center justify-between gap-2 border-b px-4 py-2">
        <div
          className="flex items-center gap-1.5"
          role="tablist"
          aria-label="Export formats"
        >
          {tabs.map((item) => (
            <button
              key={item.id}
              ref={registerTab(item.id)}
              id={tabId(item.id)}
              type="button"
              role="tab"
              aria-selected={tab === item.id}
              aria-controls={panelId}
              tabIndex={tab === item.id ? 0 : -1}
              onClick={() => setTab(item.id)}
              onKeyDown={onKeyDown}
              className={cn(
                'cursor-pointer rounded-(--just-radius-md) px-3 py-1.5 font-mono text-xs font-medium transition-colors',
                tab === item.id
                  ? 'border-border bg-card text-foreground border shadow-xs'
                  : 'text-muted hover:text-foreground hover:bg-muted/40'
              )}
            >
              {item.label}
            </button>
          ))}
        </div>

        {/* Copy Current Tab Code */}
        <div className="flex items-center gap-2">
          <CopyButton text={currentConfig.code} label={t.copyCode} />
        </div>
      </div>

      {/* Code Viewer Sub-header */}
      <CodeBlockHeader
        title={currentConfig.filename}
        className="bg-muted/10 rounded-none border-x-0 border-t-0"
      />

      {/* Syntax Highlighted Code Viewer (Shiki via Fumadocs) */}
      <div
        id={panelId}
        role="tabpanel"
        aria-labelledby={tabId(tab)}
        className="overflow-hidden"
        data-testid="code-export-panel"
      >
        <DynamicCodeBlock
          lang={currentConfig.language}
          code={currentConfig.code}
          codeblock={{
            allowCopy: false,
            'data-line-numbers': true,
            className: 'rounded-none border-0 shadow-none',
          }}
        />
      </div>
    </div>
  );
}
