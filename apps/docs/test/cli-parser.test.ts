import { describe, expect, it } from 'vitest';
import { parseCommand } from '@/components/organisms/interactive-terminal/cli-parser';

describe('cli-parser', () => {
  it('parses justui init and requests stage clear', () => {
    const result = parseCommand('justui init');
    expect(result.clearStage).toBe(true);
    expect(result.lines.some((l) => l.kind === 'info')).toBe(true);
    expect(result.lines.some((l) => l.kind === 'success')).toBe(true);
  });

  it('parses justui init with preset flag', () => {
    const result = parseCommand('justui init --preset neobrutalism');
    expect(result.clearStage).toBe(true);
    expect(result.presetChange).toBe('neobrutalism');
    expect(result.lines.some((l) => l.text.includes('neobrutalism'))).toBe(
      true
    );
  });

  it('parses justui add for single component', () => {
    const result = parseCommand('justui add button');
    expect(result.mountComponents).toEqual(['button']);
    expect(result.lines.some((l) => l.kind === 'success')).toBe(true);
  });

  it('parses justui add for multiple components', () => {
    const result = parseCommand('justui add button card switch');
    expect(result.mountComponents).toEqual(['button', 'card', 'switch']);
  });

  it('parses justui add --all', () => {
    const result = parseCommand('justui add --all');
    expect(result.mountComponents).toEqual(['button', 'switch', 'card']);
    expect(result.lines.some((l) => l.text.includes('33 components'))).toBe(
      true
    );
  });

  it('parses justui preset apply neobrutalism', () => {
    const result = parseCommand('justui preset apply neobrutalism');
    expect(result.presetChange).toBe('neobrutalism');
    expect(result.lines.some((l) => l.kind === 'success')).toBe(true);
  });

  it('parses justui preset list', () => {
    const result = parseCommand('justui preset list');
    expect(result.lines.some((l) => l.text.includes('neobrutalism'))).toBe(
      true
    );
    expect(result.lines.some((l) => l.text.includes('default'))).toBe(true);
  });

  it('parses justui version', () => {
    const result = parseCommand('justui version');
    expect(result.lines.some((l) => l.text.includes('v0.13.2'))).toBe(true);
  });

  it('parses justui help', () => {
    const result = parseCommand('justui help');
    expect(result.lines.some((l) => l.text.includes('USAGE:'))).toBe(true);
  });

  it('suggests correction for misspelled subcommand', () => {
    const result = parseCommand('justui ad buton');
    expect(result.lines.some((l) => l.kind === 'error')).toBe(true);
    expect(
      result.lines.some((l) => l.text.includes("Did you mean 'add'?"))
    ).toBe(true);
  });

  it('suggests correction for misspelled component name', () => {
    const result = parseCommand('justui add buton');
    expect(result.lines.some((l) => l.kind === 'error')).toBe(true);
    expect(
      result.lines.some((l) => l.text.includes("Did you mean 'button'?"))
    ).toBe(true);
  });

  it('returns help for empty command', () => {
    const result = parseCommand('');
    expect(result.lines.some((l) => l.text.includes('USAGE:'))).toBe(true);
  });

  it('rejects justui add with only flags and no components', () => {
    const result = parseCommand('justui add --dry-run');
    expect(result.lines.some((l) => l.kind === 'error')).toBe(true);
    expect(
      result.lines.some((l) => l.text.includes('No components specified'))
    ).toBe(true);
  });

  it('requires query argument for justui search', () => {
    const result = parseCommand('justui search');
    expect(result.lines.some((l) => l.kind === 'error')).toBe(true);
    expect(
      result.lines.some((l) => l.text.includes('Search query required'))
    ).toBe(true);
  });

  it('requires preset name for justui preset apply', () => {
    const result = parseCommand('justui preset apply');
    expect(result.lines.some((l) => l.kind === 'error')).toBe(true);
    expect(
      result.lines.some((l) => l.text.includes('Preset name required'))
    ).toBe(true);
  });

  it('supports preset aliases neo and d in preset apply', () => {
    const neoResult = parseCommand('justui preset apply neo');
    expect(neoResult.presetChange).toBe('neobrutalism');

    const dResult = parseCommand('justui preset apply d');
    expect(dResult.presetChange).toBe('default');
  });

  it('supports preset alias neo in init command', () => {
    const result = parseCommand('justui init --preset neo');
    expect(result.presetChange).toBe('neobrutalism');
  });

  it('rejects invalid preset in init command', () => {
    const result = parseCommand('justui init --preset invalid');
    expect(result.lines.some((l) => l.kind === 'error')).toBe(true);
    expect(
      result.lines.some((l) => l.text.includes("Invalid preset 'invalid'"))
    ).toBe(true);
  });

  it('suggests correction for misspelled component in diff', () => {
    const result = parseCommand('justui diff buton');
    expect(result.lines.some((l) => l.kind === 'error')).toBe(true);
    expect(
      result.lines.some((l) => l.text.includes("Did you mean 'button'?"))
    ).toBe(true);
  });
});
