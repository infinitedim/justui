import React from 'react';
import { cn } from '@/lib/cn';

export interface CodeHighlighterProps {
  code: string;
  language: 'yaml' | 'dart' | 'cli' | 'bash';
  className?: string;
  showLineNumbers?: boolean;
}

interface HighlightToken {
  type:
    | 'comment'
    | 'keyword'
    | 'string'
    | 'number'
    | 'type'
    | 'dot-enum'
    | 'key'
    | 'flag'
    | 'command'
    | 'subcommand'
    | 'punctuation'
    | 'text';
  text: string;
}

/**
 * Tokenizes a single line of YAML code.
 */
function tokenizeYamlLine(line: string): HighlightToken[] {
  const tokens: HighlightToken[] = [];
  const trimmed = line.trimStart();
  const indent = line.slice(0, line.length - trimmed.length);

  if (indent) {
    tokens.push({ type: 'text', text: indent });
  }

  if (trimmed.startsWith('#')) {
    tokens.push({ type: 'comment', text: trimmed });
    return tokens;
  }

  const keyMatch = trimmed.match(/^([a-zA-Z0-9_-]+)(:)(.*)$/);
  if (keyMatch) {
    const [, key, colon, rest] = keyMatch;
    if (key) tokens.push({ type: 'key', text: key });
    if (colon) tokens.push({ type: 'punctuation', text: colon });

    if (rest) {
      const trimmedRest = rest.trimStart();
      const restIndent = rest.slice(0, rest.length - trimmedRest.length);
      if (restIndent) tokens.push({ type: 'text', text: restIndent });

      if (trimmedRest.startsWith('#')) {
        tokens.push({ type: 'comment', text: trimmedRest });
      } else if (
        (trimmedRest.startsWith("'") && trimmedRest.endsWith("'")) ||
        (trimmedRest.startsWith('"') && trimmedRest.endsWith('"')) ||
        trimmedRest.startsWith('http://') ||
        trimmedRest.startsWith('https://')
      ) {
        tokens.push({ type: 'string', text: trimmedRest });
      } else if (trimmedRest === 'true' || trimmedRest === 'false') {
        tokens.push({ type: 'keyword', text: trimmedRest });
      } else if (/^\d+$/.test(trimmedRest)) {
        tokens.push({ type: 'number', text: trimmedRest });
      } else {
        tokens.push({ type: 'text', text: trimmedRest });
      }
    }
    return tokens;
  }

  tokens.push({ type: 'text', text: trimmed });
  return tokens;
}

/**
 * Tokenizes a single line of Dart code.
 */
function tokenizeDartLine(line: string): HighlightToken[] {
  const tokens: HighlightToken[] = [];
  let remaining = line;

  const patterns: Array<{ type: HighlightToken['type']; regex: RegExp }> = [
    { type: 'comment', regex: /^\/\/.*/ },
    { type: 'string', regex: /^'[^']*'/ },
    { type: 'string', regex: /^"[^"]*"/ },
    { type: 'number', regex: /^0x[0-9a-fA-F]+/ },
    { type: 'number', regex: /^\b\d+\b/ },
    {
      type: 'keyword',
      regex: /^\b(import|show|final|const|bool|true|false|static|class|var|return|void)\b/,
    },
    { type: 'dot-enum', regex: /^\.[a-zA-Z_][a-zA-Z0-9_]*/ },
    { type: 'key', regex: /^[a-zA-Z_][a-zA-Z0-9_]*(?=\s*:)/ },
    { type: 'type', regex: /^\b[A-Z][a-zA-Z0-9_]*\b/ },
    { type: 'punctuation', regex: /^[{}();,:]/ },
    { type: 'text', regex: /^[a-zA-Z0-9_]+/ },
    { type: 'text', regex: /^\s+/ },
    { type: 'text', regex: /^./ },
  ];

  while (remaining.length > 0) {
    let matched = false;
    for (const { type, regex } of patterns) {
      const match = remaining.match(regex);
      if (match && match[0]) {
        tokens.push({ type, text: match[0] });
        remaining = remaining.slice(match[0].length);
        matched = true;
        break;
      }
    }
    if (!matched) {
      tokens.push({ type: 'text', text: remaining.charAt(0) });
      remaining = remaining.slice(1);
    }
  }

  return tokens;
}

/**
 * Tokenizes a CLI/bash command line.
 */
function tokenizeCliLine(line: string): HighlightToken[] {
  const tokens: HighlightToken[] = [];
  const trimmed = line.trimStart();
  if (trimmed.startsWith('#')) {
    const indent = line.slice(0, line.length - trimmed.length);
    if (indent) tokens.push({ type: 'text', text: indent });
    tokens.push({ type: 'comment', text: trimmed });
    return tokens;
  }

  const parts = line.split(/(\s+)/);

  for (let i = 0; i < parts.length; i++) {
    const part = parts[i];
    if (!part) continue;

    if (/^\s+$/.test(part)) {
      tokens.push({ type: 'text', text: part });
    } else if (part === '$') {
      tokens.push({ type: 'punctuation', text: part });
    } else if (part === 'justui') {
      tokens.push({ type: 'command', text: part });
    } else if (part === 'init' || part === 'add' || part === 'preset') {
      tokens.push({ type: 'subcommand', text: part });
    } else if (part.startsWith('--')) {
      tokens.push({ type: 'flag', text: part });
    } else if (i > 0 && parts[i - 2]?.startsWith('--')) {
      tokens.push({ type: 'string', text: part });
    } else {
      tokens.push({ type: 'text', text: part });
    }
  }

  return tokens;
}

const tokenClasses: Record<HighlightToken['type'], string> = {
  comment: 'text-zinc-500 dark:text-zinc-400 italic',
  keyword: 'text-purple-600 dark:text-purple-400 font-semibold',
  string: 'text-emerald-600 dark:text-emerald-400',
  number: 'text-amber-600 dark:text-amber-400 font-medium',
  type: 'text-blue-600 dark:text-blue-400 font-semibold',
  'dot-enum': 'text-teal-600 dark:text-teal-400 font-medium',
  key: 'text-sky-600 dark:text-sky-400 font-semibold',
  flag: 'text-amber-600 dark:text-amber-400 font-medium',
  command: 'text-emerald-600 dark:text-emerald-400 font-bold',
  subcommand: 'text-sky-600 dark:text-sky-400 font-semibold',
  punctuation: 'text-foreground/60',
  text: 'text-foreground',
};

export function CodeHighlighter({
  code,
  language,
  className,
  showLineNumbers = true,
}: CodeHighlighterProps) {
  const lines = code.trimEnd().split('\n');

  return (
    <pre
      className={cn(
        'overflow-x-auto p-4 font-mono text-xs leading-relaxed md:text-[13px]',
        'bg-card text-foreground selection:bg-accent/30',
        className
      )}
      data-testid="code-highlighter"
      data-language={language}
    >
      <code>
        {lines.map((line, idx) => {
          let tokens: HighlightToken[];
          if (language === 'yaml') {
            tokens = tokenizeYamlLine(line);
          } else if (language === 'dart') {
            tokens = tokenizeDartLine(line);
          } else {
            tokens = tokenizeCliLine(line);
          }

          return (
            <div key={idx} className="table-row">
              {showLineNumbers ? (
                <span
                  className="table-cell select-none pr-4 text-right text-[11px] text-zinc-400 dark:text-zinc-600"
                  aria-hidden="true"
                >
                  {idx + 1}
                </span>
              ) : null}
              <span className="table-cell">
                {tokens.length === 0 || (tokens.length === 1 && tokens[0]?.text === '') ? (
                  <span className="inline-block min-h-[1.25em]" aria-hidden="true"> </span>
                ) : (
                  tokens.map((token, tIdx) => (
                    <span
                      key={tIdx}
                      data-token={token.type}
                      className={tokenClasses[token.type]}
                    >
                      {token.text}
                    </span>
                  ))
                )}
              </span>
            </div>
          );
        })}
      </code>
    </pre>
  );
}
