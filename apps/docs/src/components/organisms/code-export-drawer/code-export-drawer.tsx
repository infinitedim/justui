'use client';

import { useId, useMemo, useState } from 'react';
import { DynamicCodeBlock } from 'fumadocs-ui/components/dynamic-codeblock';
import { cn } from '@/lib/cn';
import { useThemeStudio } from '@/lib/theme-studio-context';
import { getStudioDictionary } from '@/lib/theme-studio-translations';
import { useRovingTabs } from '@/lib/use-roving-tabs';
import { CopyButton } from '@/components/molecules/copy-button';
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
        return { code: yamlCode, language: 'yaml' as const };
      case 'dart':
        return { code: dartCode, language: 'dart' as const };
      case 'cli':
        return { code: cliCode, language: 'bash' as const };
    }
  }, [tab, yamlCode, dartCode, cliCode]);

  // The file name is the tab label: one header instead of a tab bar plus a
  // second file-name bar.
  const tabs: Array<{ id: ExportTab; label: string }> = [
    { id: 'yaml', label: 'justui.config.yaml' },
    { id: 'dart', label: 'theme.dart' },
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
        'border-border bg-card flex flex-col overflow-hidden rounded-(--just-radius-lg) border-(length:--just-border-width) shadow-sm',
        className
      )}
      data-testid="code-export-drawer"
    >
      <div className="border-border flex flex-wrap items-center justify-between gap-2 border-b border-b-(length:--just-border-width) px-4 py-2">
        <div
          className="flex flex-wrap items-center gap-1"
          role="tablist"
          aria-label={t.export}
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
                'cursor-pointer rounded-(--just-radius-sm) px-3 py-1.5 font-mono text-xs transition-colors',
                tab === item.id
                  ? 'bg-accent text-accent-foreground font-medium'
                  : 'text-secondary hover:text-foreground'
              )}
            >
              {item.label}
            </button>
          ))}
        </div>

        <CopyButton
          text={currentConfig.code}
          label={t.copyCode}
          copiedLabel={t.copied}
        />
      </div>

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
