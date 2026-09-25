'use client';

import { useState, useRef, useEffect, useCallback } from 'react';
import { cn } from '@/lib/cn';
import { TerminalPrompt } from '@/components/molecules/terminal-prompt';
import { TerminalLine } from '@/components/molecules/terminal-line';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { parseCommand } from './cli-parser';
import { REGISTRY_COMPONENT_NAMES } from './levenshtein';
import type {
  InteractiveTerminalProps,
  TerminalBufferEntry,
} from './interactive-terminal.types';

export function InteractiveTerminal({
  lang = 'en',
  onMount,
  onPresetChange,
  onClear,
  className,
}: InteractiveTerminalProps) {
  const [buffer, setBuffer] = useState<TerminalBufferEntry[]>([]);
  const [currentInput, setCurrentInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [commandHistory, setCommandHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);

  const inputRef = useRef<HTMLInputElement>(null);
  const scrollAnchorRef = useRef<HTMLDivElement>(null);
  const entryCounterRef = useRef(0);
  const cancelledRef = useRef(false);
  const timeoutsRef = useRef<Set<ReturnType<typeof setTimeout>>>(new Set());

  const t = getHomepageDictionary(lang);

  const nextId = useCallback(() => {
    entryCounterRef.current += 1;
    return `term-${entryCounterRef.current}`;
  }, []);

  useEffect(() => {
    cancelledRef.current = false;
    const timeouts = timeoutsRef.current;
    return () => {
      cancelledRef.current = true;
      for (const id of timeouts) {
        clearTimeout(id);
      }
      timeouts.clear();
    };
  }, []);

  useEffect(() => {
    scrollAnchorRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [buffer, currentInput]);

  const executeCommand = useCallback(
    (cmd: string) => {
      const promptId = nextId();
      const result = parseCommand(cmd);

      const newEntries: TerminalBufferEntry[] = [
        {
          id: promptId,
          kind: 'prompt',
          promptPrefix: '$',
          text: cmd,
        },
      ];

      for (const line of result.lines) {
        newEntries.push({
          id: nextId(),
          kind: 'output',
          text: line.text,
          lineKind: line.kind,
        });
      }

      setBuffer((prev) => [...prev, ...newEntries]);

      if (result.clearStage) {
        onClear?.();
      }
      if (result.presetChange) {
        onPresetChange?.(result.presetChange);
      }
      if (result.mountComponents) {
        onMount?.(result.mountComponents);
      }
    },
    [nextId, onClear, onMount, onPresetChange]
  );

  const delay = useCallback((ms: number) => {
    return new Promise<void>((resolve) => {
      const id = setTimeout(() => {
        timeoutsRef.current.delete(id);
        resolve();
      }, ms);
      timeoutsRef.current.add(id);
    });
  }, []);

  const runAutomatedTyping = useCallback(
    async (command: string) => {
      if (isTyping) return;
      setIsTyping(true);
      setCurrentInput('');

      try {
        let typedSoFar = '';
        // Fast-path budget: action-chip automated typing completes under 200ms
        const AUTOMATED_BUDGET_MS = 100;
        const charDelay = Math.max(
          2,
          Math.floor(AUTOMATED_BUDGET_MS / (command.length || 1))
        );

        for (let i = 0; i < command.length; i++) {
          if (cancelledRef.current) return;
          const char = command[i];
          await delay(charDelay);

          if (cancelledRef.current) return;

          typedSoFar += char;
          setCurrentInput(typedSoFar);
        }

        await delay(20);
        if (cancelledRef.current) return;

        setCommandHistory((prev) => [command, ...prev.slice(0, 19)]);
        setHistoryIndex(-1);
        executeCommand(command);
        setCurrentInput('');
      } finally {
        setIsTyping(false);
      }
    },
    [delay, executeCommand, isTyping]
  );

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (isTyping) return;

    if (e.key === 'Enter') {
      e.preventDefault();
      const cmd = currentInput;
      if (!cmd.trim()) {
        setBuffer((prev) => [
          ...prev,
          { id: nextId(), kind: 'prompt', text: '', promptPrefix: '$' },
        ]);
        setCurrentInput('');
        return;
      }
      setCommandHistory((prev) => [cmd, ...prev.slice(0, 19)]);
      setHistoryIndex(-1);
      executeCommand(cmd);
      setCurrentInput('');
      return;
    }

    if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (commandHistory.length === 0) return;
      const nextIdx = Math.min(historyIndex + 1, commandHistory.length - 1);
      setHistoryIndex(nextIdx);
      setCurrentInput(commandHistory[nextIdx]);
      return;
    }

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (historyIndex <= 0) {
        setHistoryIndex(-1);
        setCurrentInput('');
        return;
      }
      const nextIdx = historyIndex - 1;
      setHistoryIndex(nextIdx);
      setCurrentInput(commandHistory[nextIdx]);
      return;
    }

    if (e.ctrlKey && e.key.toLowerCase() === 'c') {
      e.preventDefault();
      setBuffer((prev) => [
        ...prev,
        {
          id: nextId(),
          kind: 'prompt',
          text: `${currentInput}^C`,
          promptPrefix: '$',
        },
      ]);
      setCurrentInput('');
      return;
    }

    if (e.ctrlKey && e.key.toLowerCase() === 'l') {
      e.preventDefault();
      setBuffer([]);
      return;
    }

    if (e.key === 'Tab') {
      e.preventDefault();
      const trimmedStart = currentInput.trimStart();
      if (trimmedStart.startsWith('justui add ')) {
        const tokens = trimmedStart.split(/\s+/);
        const lastToken = currentInput.endsWith(' ')
          ? ''
          : tokens[tokens.length - 1];
        const match = REGISTRY_COMPONENT_NAMES.find((c) =>
          c.startsWith(lastToken)
        );
        if (match) {
          if (currentInput.endsWith(' ')) {
            setCurrentInput(`${currentInput}${match}`);
          } else {
            const prefix = currentInput.slice(
              0,
              currentInput.length - lastToken.length
            );
            setCurrentInput(`${prefix}${match}`);
          }
        }
      } else if (trimmedStart.startsWith('justui ')) {
        const prefix = trimmedStart.slice('justui '.length).trim();
        const subcommands = [
          'init',
          'add',
          'list',
          'search',
          'preset',
          'diff',
          'update',
          'doctor',
          'version',
          'help',
        ];
        const match = subcommands.find((s) => s.startsWith(prefix));
        if (match) {
          setCurrentInput(`justui ${match}`);
        }
      } else if ('justui'.startsWith(trimmedStart) && trimmedStart.length > 0) {
        setCurrentInput('justui ');
      }
    }
  };

  const chips = [
    { command: 'justui init', label: t.terminalChipInit || 'justui init' },
    {
      command: 'justui add button',
      label: t.terminalChipAddButton || 'justui add button',
    },
    {
      command: 'justui add switch card',
      label: t.terminalChipAddMulti || 'justui add switch card',
    },
    {
      command: 'justui preset apply neobrutalism',
      label: t.terminalChipPreset || 'justui preset apply neobrutalism',
    },
  ];

  return (
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-noninteractive-element-interactions
    <div
      role="region"
      aria-label="Interactive Terminal"
      onClick={() => inputRef.current?.focus()}
      className={cn(
        'border-border bg-card shadow-solid flex min-h-[440px] flex-1 flex-col rounded-(--just-radius-lg) border-(length:--just-border-width) text-left',
        className
      )}
    >
      {/* macOS window chrome */}
      <div className="border-border flex h-12 items-center justify-between border-(length:--just-border-width) border-b px-4">
        <div className="flex items-center gap-2">
          <span
            className="h-3 w-3 rounded-full bg-[#FF5F57]"
            aria-hidden="true"
          />
          <span
            className="h-3 w-3 rounded-full bg-[#FEBC2E]"
            aria-hidden="true"
          />
          <span
            className="h-3 w-3 rounded-full bg-[#28C840]"
            aria-hidden="true"
          />
        </div>
        <span className="text-muted font-mono text-xs select-none">
          {t.terminalTitle || 'justui@v0.14.0 ~ /my-flutter-app'}
        </span>
        <div className="w-11" aria-hidden="true" />
      </div>

      {/* Action Chips */}
      <div
        role="toolbar"
        aria-label="Terminal quick commands"
        className="border-border flex flex-wrap gap-2 border-(length:--just-border-width) border-b p-2.5"
      >
        {chips.map((chip) => (
          <button
            key={chip.command}
            type="button"
            disabled={isTyping}
            onClick={(e) => {
              e.stopPropagation();
              runAutomatedTyping(chip.command);
            }}
            className={cn(
              'rounded-full px-2.5 py-1 font-mono text-xs transition-colors',
              'border-border border-(length:--just-border-width)',
              'bg-card text-foreground hover:bg-accent hover:text-accent-foreground hover:shadow-solid',
              'disabled:cursor-not-allowed disabled:opacity-50'
            )}
          >
            {chip.label}
          </button>
        ))}
      </div>

      {/* Terminal Buffer */}
      <div className="flex min-h-[280px] flex-1 flex-col overflow-y-auto p-4 font-mono text-xs leading-6">
        {buffer.map((entry) => {
          if (entry.kind === 'prompt') {
            return (
              <TerminalPrompt
                key={entry.id}
                prefix={entry.promptPrefix ?? '$'}
                command={entry.text}
              />
            );
          }
          return (
            <TerminalLine key={entry.id} kind={entry.lineKind}>
              {entry.text}
            </TerminalLine>
          );
        })}

        {/* Live typing / interactive prompt */}
        <TerminalPrompt prefix="$" command={currentInput} cursor={true} />
        <div ref={scrollAnchorRef} />
      </div>

      {/* Hidden input to capture keyboard events */}
      <input
        ref={inputRef}
        type="text"
        value={currentInput}
        onChange={(e) => setCurrentInput(e.target.value)}
        onKeyDown={handleKeyDown}
        disabled={isTyping}
        className="sr-only"
        aria-label="Terminal input"
        autoCapitalize="none"
        autoCorrect="off"
        spellCheck={false}
      />
    </div>
  );
}
