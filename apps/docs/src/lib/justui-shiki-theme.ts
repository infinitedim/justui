/**
 * Shiki themes for docs code blocks, built from the same palette as the
 * --just-syn-* tokens in globals.css so fenced code (Shiki) and the
 * playground (CodeLines) match.
 */
type Mode = 'light' | 'dark';

const PALETTE = {
  light: {
    fg: '#18181b',
    bg: '#ffffff',
    keyword: '#733ea4',
    string: '#0f6a31',
    type: '#005c9b',
    number: '#994a00',
    comment: '#6b6b6b',
  },
  dark: {
    fg: '#f8fafc',
    bg: '#27272a',
    keyword: '#c9a3f5',
    string: '#83d494',
    type: '#74c2ee',
    number: '#f6ab6b',
    comment: '#8f8f96',
  },
} as const;

function build(mode: Mode) {
  const p = PALETTE[mode];
  return {
    name: `justui-${mode}`,
    type: mode,
    colors: {
      'editor.foreground': p.fg,
      'editor.background': p.bg,
    },
    tokenColors: [
      {
        scope: ['comment', 'punctuation.definition.comment'],
        settings: { foreground: p.comment, fontStyle: 'italic' },
      },
      {
        scope: ['string', 'string.quoted', 'punctuation.definition.string'],
        settings: { foreground: p.string },
      },
      {
        scope: ['constant.numeric', 'constant.language', 'constant.character'],
        settings: { foreground: p.number },
      },
      {
        scope: [
          'keyword',
          'keyword.control',
          'keyword.declaration',
          'storage',
          'storage.type',
          'storage.modifier',
        ],
        settings: { foreground: p.keyword },
      },
      {
        scope: [
          'support.class',
          'support.type',
          'entity.name.type',
          'entity.name.class',
          'entity.other.inherited-class',
        ],
        settings: { foreground: p.type },
      },
    ],
  } as const;
}

export const justuiLight = build('light');
export const justuiDark = build('dark');
