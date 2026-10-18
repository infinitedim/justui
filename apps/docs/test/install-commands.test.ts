import { describe, expect, it } from 'vitest';
import { INSTALL_COMMANDS, commandSegments } from '@/lib/install-commands';

describe('commandSegments', () => {
  it('breaks after spaces and slashes so no line starts with a space', () => {
    expect(commandSegments(INSTALL_COMMANDS.unix)).toEqual([
      'curl ',
      '-fsSL ',
      'https://',
      'justui.vercel.app/',
      'install.sh ',
      '| sh',
    ]);
    expect(commandSegments(INSTALL_COMMANDS.windows)).toEqual([
      'irm ',
      'https://',
      'justui.vercel.app/',
      'install.ps1 ',
      '| iex',
    ]);
  });

  it('joins back to the exact command', () => {
    for (const command of Object.values(INSTALL_COMMANDS)) {
      expect(commandSegments(command).join('')).toBe(command);
      for (const segment of commandSegments(command)) {
        expect(segment.startsWith(' ')).toBe(false);
      }
    }
  });
});
