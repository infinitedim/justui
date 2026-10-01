'use client';

import {
  useState,
  useRef,
  useEffect,
  useCallback,
  forwardRef,
  useImperativeHandle,
} from 'react';
import { cn } from '@/lib/cn';
import { TerminalPrompt } from '@/components/molecules/terminal-prompt';
import { TerminalLine } from '@/components/molecules/terminal-line';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { parseCommand } from './cli-parser';
import { REGISTRY_COMPONENT_NAMES } from './levenshtein';
import type {
  InteractiveTerminalProps,
  InteractiveTerminalHandle,
  TerminalBufferEntry,
} from './interactive-terminal.types';

export const InteractiveTerminal = forwardRef<
  InteractiveTerminalHandle,
  InteractiveTerminalProps
>(function InteractiveTerminal(
  {
    lang = 'en',
    onMount,
    onPresetChange,
    onClear,
    className,
  }: InteractiveTerminalProps,
  ref
) {
  const [buffer, setBuffer] = useState<TerminalBufferEntry[]>([]);
  const [currentInput, setCurrentInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [commandHistory, setCommandHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);

  const inputRef = useRef<HTMLInputElement>(null);
  const terminalBufferRef = useRef<HTMLDivElement>(null);
  const entryCounterRef = useRef(0);
  const cancelledRef = useRef(false);
  const isTypingRef = useRef(false);
  const timeoutsRef = useRef<Set<ReturnType<typeof setTimeout>>>(new Set());
  const resolversRef = useRef<Set<() => void>>(new Set());

  const t = getHomepageDictionary(lang);

  const nextId = useCallback(() => {
    entryCounterRef.current += 1;
    return `term-${entryCounterRef.current}`;
  }, []);

  useEffect(() => {
    cancelledRef.current = false;
    const timeouts = timeoutsRef.current;
    const resolvers = resolversRef.current;
    return () => {
      cancelledRef.current = true;
      for (const id of timeouts) {
        clearTimeout(id);
      }
      timeouts.clear();
      for (const resolve of resolvers) {
        resolve();
      }
      resolvers.clear();
    };
  }, []);

  useEffect(() => {
    const el = terminalBufferRef.current;
    if (el) {
      el.scrollTop = el.scrollHeight;
    }
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
      const onDone = () => {
        timeoutsRef.current.delete(id);
        resolversRef.current.delete(onDone);
        resolve();
      };
      resolversRef.current.add(onDone);
      const id = setTimeout(onDone, ms);
      timeoutsRef.current.add(id);
    });
  }, []);

  const runAutomatedTyping = useCallback(
    async (command: string) => {
      if (isTypingRef.current) return;
      isTypingRef.current = true;
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
        isTypingRef.current = false;
        if (!cancelledRef.current) {
          setIsTyping(false);
        }
      }
    },
    [delay, executeCommand]
  );

  useImperativeHandle(
    ref,
    () => ({
      runCommand: (command: string) => {
        runAutomatedTyping(command);
      },
    }),
    [runAutomatedTyping]
  );

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (isTypingRef.current) return;

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
    { command: 'justui init', label: t.terminalChipInit || 'justui init' },
  ];

  return (
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-noninteractive-element-interactions
    <div
      role="region"
      aria-label={t.terminalRegionLabel}
      onClick={() => {
        const hasSelection =
          typeof window !== 'undefined' &&
          Boolean(window.getSelection?.()?.toString());
        if (hasSelection) return;
        if (
          typeof window !== 'undefined' &&
          (!window.matchMedia || window.matchMedia('(pointer: fine)').matches)
        ) {
          inputRef.current?.focus();
        }
      }}
      className={cn(
        'border-border bg-card shadow-solid flex min-h-110 flex-1 flex-col rounded-(--just-radius-lg) border-(length:--just-border-width) text-left',
        className
      )}
    >
      {/* Header */}
      <div className="border-border flex h-12 items-center overflow-hidden border-(length:--just-border-width) border-b px-4">
        <span className="text-muted font-mono text-xs select-none truncate">
          {t.terminalTitle || 'justui@v0.14.0 ~ /my-flutter-app'}
        </span>
      </div>

      {/* Action Chips */}
      <div
        role="toolbar"
        aria-label={t.terminalChipsLabel}
        className="border-border flex flex-wrap gap-2 border-(length:--just-border-width) border-b p-2.5"
      >
        {chips.map((chip) => (
          <button
            key={chip.command}
            type="button"
            disabled={isTyping}
            onClick={(e) => {
              e.stopPropagation();
              if (!isTypingRef.current) {
                runAutomatedTyping(chip.command);
              }
            }}
            className={cn(
              'rounded-(--just-radius-sm) px-2.5 py-1 font-mono text-xs transition-colors',
              'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2',
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
      <div
        ref={terminalBufferRef}
        className="flex min-h-70 flex-1 flex-col overflow-y-auto p-4 font-mono text-xs leading-6"
      >
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
      </div>

      {/* Hidden input to capture keyboard events */}
      <input
        ref={inputRef}
        type="text"
        value={currentInput}
        onChange={(e) => {
          if (!isTypingRef.current) {
            setCurrentInput(e.target.value);
          }
        }}
        onKeyDown={handleKeyDown}
        disabled={isTyping}
        className="sr-only"
        aria-label={t.terminalInputLabel}
        autoCapitalize="none"
        autoCorrect="off"
        spellCheck={false}
      />

      {/* Keyboard hints footer */}
      <div className="border-border text-muted flex items-center overflow-x-auto whitespace-nowrap border-(length:--just-border-width) border-t px-4 py-2 text-xs select-none">
        <span>
          {t.terminalShortcuts ||
            '[Tab] Autocomplete | [Up/Down] History | [Enter] Run'}
        </span>
      </div>
    </div>
  );
});

InteractiveTerminal.displayName = 'InteractiveTerminal';
