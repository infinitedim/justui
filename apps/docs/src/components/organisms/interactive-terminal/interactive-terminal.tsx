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
import {
  INITIAL_SESSION,
  SUBCOMMANDS,
  parseCommand,
  type CliSession,
} from './cli-parser';
import { REGISTRY_COMPONENT_NAMES } from './levenshtein';
import type {
  InteractiveTerminalProps,
  InteractiveTerminalHandle,
  TerminalBufferEntry,
} from './interactive-terminal.types';

/** Already run when the page loads, so the stage starts with a result. */
export const INITIAL_COMMAND = 'justui add button';

const TRY_COMMANDS = [
  'justui add switch card',
  'justui preset apply neobrutalism',
  'justui list',
] as const;

// Box-drawing frames from logger::panel/summary. Web mono fonts lack these
// glyphs, so the fallback font misaligns the frame; the browser shows the
// framed text without its border (the parser output itself stays exact).
const FRAME_ONLY = /^[\s\u2500-\u257f]+$/;
const FRAME_SIDES = /^\u2502 ?(.*?)\s*\u2502$/;

function forDisplay(
  lines: { kind: TerminalBufferEntry['lineKind']; text: string }[]
) {
  return lines
    .filter((line) => !FRAME_ONLY.test(line.text))
    .map((line) => {
      const inner = FRAME_SIDES.exec(line.text);
      return inner ? { ...line, text: inner[1] ?? '' } : line;
    })
    .filter(
      (line, i, all) =>
        line.text.trim() !== '' || all[i - 1]?.text.trim() !== ''
    );
}

function toEntries(
  command: string,
  lines: { kind: TerminalBufferEntry['lineKind']; text: string }[],
  nextId: () => string
): TerminalBufferEntry[] {
  return [
    { id: nextId(), kind: 'prompt', promptPrefix: '$', text: command },
    ...forDisplay(lines).map((line) => ({
      id: nextId(),
      kind: 'output' as const,
      text: line.text,
      lineKind: line.kind,
    })),
  ];
}

export const InteractiveTerminal = forwardRef<
  InteractiveTerminalHandle,
  InteractiveTerminalProps
>(function InteractiveTerminal(
  { lang = 'en', onMount, onPresetChange, className }: InteractiveTerminalProps,
  ref
) {
  const entryCounterRef = useRef(0);
  const nextId = useCallback(() => {
    entryCounterRef.current += 1;
    return `term-${entryCounterRef.current}`;
  }, []);

  const [initial] = useState(() => {
    const result = parseCommand(INITIAL_COMMAND, INITIAL_SESSION);
    return {
      result,
      entries: toEntries(INITIAL_COMMAND, result.lines, nextId),
    };
  });
  const [buffer, setBuffer] = useState<TerminalBufferEntry[]>(initial.entries);
  const sessionRef = useRef<CliSession>(initial.result.session);
  const [currentInput, setCurrentInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [commandHistory, setCommandHistory] = useState<string[]>([
    INITIAL_COMMAND,
  ]);
  const [historyIndex, setHistoryIndex] = useState(-1);

  const inputRef = useRef<HTMLInputElement>(null);
  const terminalBufferRef = useRef<HTMLDivElement>(null);
  const cancelledRef = useRef(false);
  const isTypingRef = useRef(false);
  const timeoutsRef = useRef<Set<ReturnType<typeof setTimeout>>>(new Set());
  const resolversRef = useRef<Set<() => void>>(new Set());

  const t = getHomepageDictionary(lang);

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
  }, [buffer]);

  const executeCommand = useCallback(
    (cmd: string) => {
      const result = parseCommand(cmd, sessionRef.current);
      sessionRef.current = result.session;
      setBuffer((prev) => [...prev, ...toEntries(cmd, result.lines, nextId)]);

      if (result.presetChange) {
        onPresetChange?.(result.presetChange);
      }
      if (result.mountComponents && result.mountComponents.length > 0) {
        onMount?.(result.mountComponents);
      }
    },
    [nextId, onMount, onPresetChange]
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
        // Typing a chip finishes in about 100ms: enough to read as typed,
        // short enough not to make anyone wait.
        const charDelay = Math.max(2, Math.floor(100 / (command.length || 1)));

        let typedSoFar = '';
        for (const char of command) {
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
          setCurrentInput(
            `${currentInput.slice(0, currentInput.length - lastToken.length)}${match}`
          );
        }
      } else if (trimmedStart.startsWith('justui ')) {
        const prefix = trimmedStart.slice('justui '.length).trim();
        const match = SUBCOMMANDS.find((s) => s.startsWith(prefix));
        if (match) {
          setCurrentInput(`justui ${match}`);
        }
      } else if ('justui'.startsWith(trimmedStart) && trimmedStart.length > 0) {
        setCurrentInput('justui ');
      }
    }
  };

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
        // On touch screens only a tap on the prompt itself should raise the
        // keyboard, not every tap that scrolls the output.
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
      <div className="border-border flex min-h-11 flex-wrap items-center justify-between gap-x-4 gap-y-1 border-b border-b-(length:--just-border-width) px-4 py-2">
        <span className="text-foreground font-mono text-xs">
          ~/my-flutter-app
        </span>
        <span className="text-muted text-xs">{t.terminalNote}</span>
      </div>

      <div
        ref={terminalBufferRef}
        className="flex max-h-105 min-h-70 flex-1 flex-col overflow-y-auto p-4"
      >
        {buffer.map((entry) =>
          entry.kind === 'prompt' ? (
            <TerminalPrompt
              key={entry.id}
              prefix={entry.promptPrefix ?? '$'}
              command={entry.text}
            />
          ) : (
            <TerminalLine key={entry.id} kind={entry.lineKind}>
              {entry.text}
            </TerminalLine>
          )
        )}

        <label className="flex items-center gap-2 font-mono text-xs leading-6">
          <span className="text-accent-text shrink-0 select-none">$</span>
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
            aria-label={t.terminalInputLabel}
            readOnly={isTyping}
            enterKeyHint="go"
            autoCapitalize="none"
            autoCorrect="off"
            autoComplete="off"
            spellCheck={false}
            className="text-foreground caret-accent-text min-w-0 flex-1 bg-transparent outline-none"
          />
        </label>
      </div>

      <div className="border-border flex flex-wrap items-center gap-2 border-t border-t-(length:--just-border-width) px-4 py-2.5">
        <span className="text-muted text-xs">{t.terminalTry}</span>
        {TRY_COMMANDS.map((command) => (
          <button
            key={command}
            type="button"
            disabled={isTyping}
            onClick={(e) => {
              e.stopPropagation();
              runAutomatedTyping(command);
            }}
            className={cn(
              'just-press border-border bg-card text-foreground rounded-(--just-radius-sm) border-(length:--just-border-width) px-2 py-1 font-mono text-xs',
              'hover:bg-accent-muted focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2',
              'disabled:cursor-not-allowed disabled:opacity-50'
            )}
          >
            {command.slice('justui '.length)}
          </button>
        ))}
        <span className="text-muted ml-auto hidden text-xs pointer-fine:inline">
          {t.terminalShortcuts}
        </span>
      </div>
    </div>
  );
});

InteractiveTerminal.displayName = 'InteractiveTerminal';
