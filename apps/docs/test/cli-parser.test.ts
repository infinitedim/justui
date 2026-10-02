import { describe, expect, it } from 'vitest';
import {
  INITIAL_SESSION,
  parseCommand,
  type CliSession,
} from '@/components/organisms/interactive-terminal/cli-parser';

function run(command: string, session: CliSession) {
  const result = parseCommand(command, session);
  return { ...result, text: result.lines.map((l) => l.text).join('\n') };
}

describe('CLI simulator parses commands and manages session', () => {
  const afterButton = run('justui add button -y', INITIAL_SESSION).session;
  const afterSwitchCard = run('justui add switch card -y', afterButton).session;

  it('add button (fresh project)', () => {
    const res = run('justui add button -y', INITIAL_SESSION);
    expect(res.mountComponents).toEqual(['button']);
    expect(res.session.installed).toContain('button');
    expect(res.session.installed).toContain('_shared_pressable');
    expect(res.text).toContain('Component "button" added successfully');
    expect(res.lines.some((l) => l.kind === 'success')).toBe(true);
  });

  it('add switch card (button already installed)', () => {
    const res = run('justui add switch card -y', afterButton);
    expect(res.mountComponents).toEqual(['switch', 'card']);
    expect(res.session.installed).toContain('button');
    expect(res.session.installed).toContain('switch');
    expect(res.session.installed).toContain('card');
    expect(res.text).toContain('Component "switch" added successfully');
    expect(res.text).toContain('Component "card" added successfully');
  });

  it('list', () => {
    const res = run('justui list', afterSwitchCard);
    expect(res.lines.length).toBeGreaterThan(10);
    expect(res.text).toContain('button');
    expect(res.text).toContain('card');
  });

  it('preset list', () => {
    const res = run('justui preset list', afterSwitchCard);
    expect(res.text).toContain('Available Presets');
    expect(res.text).toContain('default');
    expect(res.text).toContain('neobrutalism');
  });

  it('search date', () => {
    const res = run('justui search date', afterSwitchCard);
    expect(res.text).toContain('Search results for "date"');
  });

  it('diff button', () => {
    const res = run('justui diff button', afterSwitchCard);
    expect(res.text).toContain('Comparing component "button" with registry');
    expect(res.text).toContain('Up to date');
  });

  it('update', () => {
    const res = run('justui update -y', afterSwitchCard);
    expect(res.text).toContain('All components are up-to-date');
  });

  it('add with an unknown component', () => {
    const res = run('justui add buton -y', afterSwitchCard);
    expect(res.lines.some((l) => l.kind === 'error')).toBe(true);
    expect(res.text).toContain('Component "buton" not found in registry');
  });

  it('unrecognized subcommand', () => {
    const res = run('justui ad', afterSwitchCard);
    expect(res.text).toContain("unrecognized subcommand 'ad'");
    expect(res.text).toContain("tip: a similar subcommand exists: 'add'");
  });

  it('preset apply neobrutalism', () => {
    const res = run('justui preset apply neobrutalism -y', afterSwitchCard);
    expect(res.presetChange).toBe('neobrutalism');
    expect(res.session.preset).toBe('neobrutalism');
    expect(res.text).toContain('Preset "neobrutalism" applied successfully');
  });

  it('init in an initialized project', () => {
    const res = run('justui init -y', afterSwitchCard);
    expect(res.lines.some((l) => l.kind === 'warning')).toBe(true);
    expect(res.text).toContain('justui.config.yaml already exists');
  });

  it('help', () => {
    const res = run('justui help', INITIAL_SESSION);
    expect(res.text).toContain('justui');
    expect(res.text).toContain('JustUI CLI');
    expect(res.text).toContain('Usage:');
  });
});
