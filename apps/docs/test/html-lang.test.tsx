import { render } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { HtmlLang } from '@/components/html-lang';

describe('HtmlLang Component', () => {
  it('updates document.documentElement.lang to the given language', () => {
    document.documentElement.lang = 'en';

    render(<HtmlLang lang="id" />);
    expect(document.documentElement.lang).toBe('id');

    render(<HtmlLang lang="en" />);
    expect(document.documentElement.lang).toBe('en');
  });
});
