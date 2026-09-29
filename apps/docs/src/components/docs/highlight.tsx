import { cn } from '@/lib/cn';

export interface CodeToken {
  text: string;
  className: string;
}

export interface CodeLine {
  tokens: CodeToken[];
}

// comment | string | .enumShorthand | Type | keyword | number
const TOKEN_RE =
  /(\/\/.*$)|('(?:[^'\\]|\\.)*')|((?<=[:\s(,])\.[a-z]\w*)|(\b[A-Z]\w*)|(\b(?:const|return|final|void|true|false|null|import|as|show|async|await|extends|class|super)\b)|(\b\d+(?:\.\d+)?\b)/g;

const CLASS_BY_GROUP = [
  '',
  'text-syn-comment italic',
  'text-syn-string',
  'text-syn-number',
  'text-syn-type',
  'text-syn-keyword font-medium',
  'text-syn-number',
];

/** Small Dart tokenizer for the interactive playground. Fenced code blocks use Shiki. */
export function highlightDart(code: string): CodeLine[] {
  return code.split('\n').map((line) => {
    const tokens: CodeToken[] = [];
    let last = 0;
    TOKEN_RE.lastIndex = 0;
    let match: RegExpExecArray | null;
    while ((match = TOKEN_RE.exec(line))) {
      if (match.index > last) {
        tokens.push({ text: line.slice(last, match.index), className: '' });
      }
      let group = 1;
      while (!match[group]) group += 1;
      tokens.push({ text: match[0], className: CLASS_BY_GROUP[group] });
      last = match.index + match[0].length;
    }
    if (last < line.length) {
      tokens.push({ text: line.slice(last), className: '' });
    }
    return { tokens: tokens.length ? tokens : [{ text: '', className: '' }] };
  });
}

export function CodeLines({
  code,
  className,
}: {
  code: string;
  className?: string;
}) {
  const lines = highlightDart(code);
  return (
    <div
      className={cn(
        'text-foreground overflow-x-auto py-5 font-mono text-[13px] leading-[22px]',
        className
      )}
    >
      {lines.map((line, i) => (
        <div key={i} className="min-h-[22px] px-5 whitespace-pre">
          {line.tokens.map((token, j) => (
            <span key={j} className={token.className}>
              {token.text}
            </span>
          ))}
        </div>
      ))}
    </div>
  );
}
