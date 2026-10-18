/**
 * The landing's cut sequence as a pure function of scroll progress `p`
 * (0..1): which inline style each node gets on a frame (handoff apply()).
 * Part 07 is cut from the runner, lifts, flies to the file tree while it
 * morphs into its file row, and the folder, the other files, the shared
 * folder and the checksum line reveal in turn. The organism writes these
 * styles in effects only.
 */

export const CUT_EASE = 'cubic-bezier(0.16, 1, 0.3, 1)';

const FADE = `opacity 220ms ${CUT_EASE}`;

/** Inline style properties the sequence writes. */
export type CutStyle = Partial<
  Record<
    | 'opacity'
    | 'transform'
    | 'clipPath'
    | 'transition'
    | 'willChange'
    | 'backgroundColor'
    | 'color',
    string
  >
>;

/** Offset from the part's slot in the runner to its row in the tree. */
export interface CutGeometry {
  dx: number;
  dy: number;
}

export interface CutFrameOptions {
  /** Reduced motion: before/after steps with fades, nothing moves. */
  stepped: boolean;
  geometry: CutGeometry;
  /** Files after the main one in the part folder. */
  rows: number;
}

export interface CutFrame {
  label: CutStyle;
  scissors: CutStyle;
  /** Both gate lines. */
  gate: CutStyle;
  slot: CutStyle;
  cutTag: CutStyle;
  mover: CutStyle;
  moverButton: CutStyle;
  moverRow: CutStyle;
  folder: CutStyle;
  /** The main file row the part lands on. */
  landing: CutStyle;
  rows: readonly CutStyle[];
  shared: CutStyle;
  verify: CutStyle;
  /** How far the slot is lifted (px); geometry is measured without it. */
  lift: number;
}

/** Exponential ease-out: fast start, long settle. */
export function expoOut(t: number): number {
  return t >= 1 ? 1 : 1 - 2 ** (-10 * t);
}

/** A style number without float noise (`0.44999999999999996` -> `0.45`). */
function fixed(value: number): string {
  return String(Math.round(value * 1e4) / 1e4);
}

function clamp01(value: number): number {
  return Math.min(1, Math.max(0, value));
}

/** Local progress of `p` through the window [from, to]. */
function span(p: number, from: number, to: number): number {
  return clamp01((p - from) / (to - from));
}

function reveal(amount: number, stepped: boolean): CutStyle {
  return stepped
    ? { opacity: fixed(amount), clipPath: 'none', transition: FADE }
    : {
        opacity: '1',
        clipPath: `inset(0 ${fixed(100 - 100 * amount)}% 0 0)`,
        transition: 'none',
      };
}

function fadeTo(amount: number, stepped: boolean): CutStyle {
  return { opacity: fixed(amount), transition: stepped ? FADE : 'none' };
}

/** The part leaving the runner: slot, flying copy and its morph. */
function flight(
  p: number,
  { stepped, geometry }: CutFrameOptions
): Pick<CutFrame, 'slot' | 'mover' | 'moverButton' | 'moverRow' | 'lift'> {
  if (stepped) {
    return {
      slot: {
        opacity: p >= 0.5 ? '0' : '1',
        transform: 'none',
        transition: FADE,
      },
      mover: { opacity: '0', transform: 'none', willChange: 'auto' },
      moverButton: { opacity: '1' },
      moverRow: { opacity: '0' },
      lift: 0,
    };
  }
  const lift = 4 * expoOut(span(p, 0.24, 0.3));
  const travel = expoOut(span(p, 0.3, 0.7));
  const morph = span(p, 0.46, 0.62);
  const x = geometry.dx * travel;
  const y = geometry.dy * travel - 4 * (1 - travel);
  return {
    slot: {
      opacity: p < 0.3 ? '1' : '0',
      transform: `translateY(${fixed(-lift)}px)`,
      transition: 'none',
    },
    mover: {
      opacity: p >= 0.3 && p < 0.72 ? '1' : '0',
      transform: `translate3d(${fixed(x)}px, ${fixed(y)}px, 0)`,
      willChange: p > 0.2 && p < 0.8 ? 'transform' : 'auto',
    },
    moverButton: { opacity: fixed(1 - morph) },
    moverRow: { opacity: fixed(morph) },
    lift,
  };
}

/** Styles for every node of the cut sequence at progress `p`. */
export function cutFrame(p: number, options: CutFrameOptions): CutFrame {
  const { stepped, rows } = options;
  const after = p >= 0.5 ? 1 : 0;
  const armed = stepped ? after === 1 : p > 0.06;
  const cut = stepped ? after : expoOut(span(p, 0.1, 0.24));
  const at = (from: number, to: number) =>
    stepped ? after : span(p, from, to);
  return {
    label: {
      backgroundColor: armed ? 'var(--ip-inverse)' : 'transparent',
      color: armed ? 'var(--ip-on-inverse)' : 'var(--ip-text-primary)',
      transition: 'background-color 150ms ease-out, color 150ms ease-out',
    },
    scissors: {
      opacity: armed ? '1' : '0',
      transition: 'opacity 150ms ease-out',
    },
    gate: {
      transform: `scaleY(${fixed(1 - 0.55 * cut)})`,
      transition: stepped ? `transform 200ms ${CUT_EASE}` : 'none',
    },
    ...flight(p, options),
    cutTag: fadeTo(at(0.72, 0.8), stepped),
    folder: reveal(at(0.6, 0.68), stepped),
    landing: fadeTo(stepped ? after : p >= 0.7 ? 1 : 0, stepped),
    rows: Array.from({ length: rows }, (_, index) =>
      reveal(at(0.72 + 0.04 * index, 0.77 + 0.04 * index), stepped)
    ),
    shared: reveal(at(0.86, 0.9), stepped),
    verify: fadeTo(at(0.9, 0.97), stepped),
  };
}
