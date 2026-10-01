import { readFileSync } from 'node:fs';
import path from 'node:path';
import { describe, expect, it } from 'vitest';
import {
  INITIAL_SESSION,
  parseCommand,
  type CliSession,
} from '@/components/organisms/interactive-terminal/cli-parser';

/**
 * Transcripts in test/fixtures/cli were recorded from the real binary
 * (`target/release/justui --no-color`) in a fresh `justui init -y` project,
 * running the commands in the order below. The simulator must reproduce
 * them byte for byte.
 */
function fixture(name: string): string {
  return readFileSync(
    path.join(__dirname, 'fixtures/cli', `${name}.txt`),
    'utf-8'
  ).replace(/\n$/, '');
}

function run(command: string, session: CliSession) {
  const result = parseCommand(command, session);
  return { ...result, text: result.lines.map((l) => l.text).join('\n') };
}

describe('CLI simulator matches recorded justui output', () => {
  const afterButton = run('justui add button -y', INITIAL_SESSION).session;
  const afterSwitchCard = run('justui add switch card -y', afterButton).session;

  it('add button (fresh project)', () => {
    expect(run('justui add button -y', INITIAL_SESSION).text).toBe(
      fixture('add-button')
    );
  });

  it('add switch card (button already installed)', () => {
    expect(run('justui add switch card -y', afterButton).text).toBe(
      fixture('add-switch-card')
    );
  });

  it('list', () => {
    expect(run('justui list', afterSwitchCard).text).toBe(fixture('list'));
  });

  it('preset list', () => {
    expect(run('justui preset list', afterSwitchCard).text).toBe(
      fixture('preset-list')
    );
  });

  it('search date', () => {
    expect(run('justui search date', afterSwitchCard).text).toBe(
      fixture('search-date')
    );
  });

  it('diff button', () => {
    expect(run('justui diff button', afterSwitchCard).text).toBe(
      fixture('diff-button')
    );
  });

  it('update', () => {
    expect(run('justui update -y', afterSwitchCard).text).toBe(
      fixture('update')
    );
  });

  it('add with an unknown component', () => {
    expect(run('justui add buton -y', afterSwitchCard).text).toBe(
      fixture('add-unknown')
    );
  });

  it('unrecognized subcommand', () => {
    expect(run('justui ad', afterSwitchCard).text).toBe(
      fixture('unknown-subcommand')
    );
  });

  it('preset apply neobrutalism', () => {
    expect(
      run('justui preset apply neobrutalism -y', afterSwitchCard).text
    ).toBe(fixture('preset-apply-neobrutalism'));
  });

  it('init in an initialized project', () => {
    expect(run('justui init -y', afterSwitchCard).text).toBe(
      fixture('init-again')
    );
  });

  it('help', () => {
    expect(run('justui help', INITIAL_SESSION).text).toBe(fixture('help'));
  });
});
