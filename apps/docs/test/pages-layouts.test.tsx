/* eslint-disable @typescript-eslint/no-explicit-any */
import { render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import type { ReactNode } from 'react';

// Mock Next.js fonts
vi.mock('next/font/google', () => ({
  IBM_Plex_Mono: () => ({ variable: 'font-mono' }),
  IBM_Plex_Sans: () => ({ variable: 'font-sans' }),
}));

// Mock next-themes
vi.mock('next-themes', () => ({
  ThemeProvider: ({ children }: { children: ReactNode }) => (
    <div data-testid="theme-provider">{children}</div>
  ),
  useTheme: () => ({ resolvedTheme: 'dark', setTheme: vi.fn() }),
}));

// Mock next/navigation
const mockNotFound = vi.fn();
(globalThis as any).mockNotFound = mockNotFound;
vi.mock('next/navigation', () => ({
  usePathname: () => '/id',
  notFound: () => {
    mockNotFound();
    throw new Error('NEXT_NOT_FOUND');
  },
}));

// Mock next/link
vi.mock('next/link', () => ({
  default: ({ children, href }: {children: ReactNode, href: string}) => <a href={href}>{children}</a>,
}));

// Mock fumadocs-ui
vi.mock('fumadocs-ui/provider/next', () => ({
  RootProvider: ({ children }: { children: ReactNode }) => (
    <div data-testid="root-provider">{children}</div>
  ),
}));

vi.mock('fumadocs-ui/layouts/docs', () => ({
  DocsLayout: ({ children }: { children: ReactNode }) => (
    <div data-testid="docs-layout">{children}</div>
  ),
}));

vi.mock('fumadocs-ui/page', () => ({
  DocsPage: ({ children }: { children: ReactNode }) => (
    <div data-testid="docs-page">{children}</div>
  ),
  DocsBody: ({ children }: { children: ReactNode }) => <div>{children}</div>,
  DocsTitle: ({ children }: { children: ReactNode }) => <h1>{children}</h1>,
  DocsDescription: ({ children }: { children: ReactNode }) => <p>{children}</p>,
}));

// Mock github API stars fetch
vi.mock('@/lib/github', () => ({
  fetchStarCount: vi.fn().mockResolvedValue(150),
  githubUrl: 'https://github.com/infinitedim/justui',
}));

// Mock source loader
const mockGetPage = vi.fn();
const mockGenerateParams = vi.fn().mockReturnValue([{ lang: 'en', slug: ['intro'] }]);
(globalThis as any).mockGetPage = mockGetPage;
(globalThis as any).mockGenerateParams = mockGenerateParams;
vi.mock('@/lib/source', () => ({
  source: {
    pageTree: {
      id: {},
      en: {},
    },
    getPage: (slug: string[], lang: string) => mockGetPage(slug, lang),
    generateParams: () => mockGenerateParams(),
  },
}));

// Imports of pages and layouts
import RootLayout from '@/app/layout';
import LangLayout from '@/app/[lang]/layout';
import ComponentsPage, { generateStaticParams as componentsStaticParams } from '@/app/[lang]/components/page';
import Layout from '@/app/[lang]/docs/layout';
import Page, { generateStaticParams as docsStaticParams } from '@/app/[lang]/docs/[[...slug]]/page';

describe('App Router Pages and Layouts', () => {
  describe('RootLayout', () => {
    it('renders HTML body and ThemeProvider', () => {
      const consoleError = console.error;
      console.error = vi.fn((msg, ...args) => {
        if (typeof msg === 'string' && msg.includes('cannot be a child of')) {
          return;
        }
        consoleError(msg, ...args);
      });

      render(
        <RootLayout>
          <div data-testid="test-child" />
        </RootLayout>
      );
      expect(screen.getByTestId('theme-provider')).toBeInTheDocument();
      expect(screen.getByTestId('test-child')).toBeInTheDocument();

      console.error = consoleError;
    });
  });

  describe('LangLayout', () => {
    it('resolves params Promise and renders RootProvider', async () => {
      const layout = await LangLayout({
        params: Promise.resolve({ lang: 'en' }),
        children: <div data-testid="lang-child" />,
      });
      render(layout);
      expect(screen.getByTestId('root-provider')).toBeInTheDocument();
      expect(screen.getByTestId('lang-child')).toBeInTheDocument();
    });
  });

  describe('ComponentsPage', () => {
    it('renders components catalog correctly', async () => {
      const page = await ComponentsPage({
        params: Promise.resolve({ lang: 'en' }),
      });
      render(page);
      expect(screen.getByRole('heading', { level: 1, name: 'Components' })).toBeInTheDocument();
      expect(screen.getByText('JustButton')).toBeInTheDocument();
    });

    it('returns static params', async () => {
      const params = await componentsStaticParams();
      expect(params).toEqual([{ lang: 'id' }, { lang: 'en' }]);
    });
  });

  describe('Layout (DocsLayout)', () => {
    it('resolves params and renders DocsLayout wrapper', async () => {
      const layout = await Layout({
        params: Promise.resolve({ lang: 'en' }),
        children: <div data-testid="docs-child" />,
      });
      render(layout);
      expect(screen.getByTestId('docs-layout')).toBeInTheDocument();
      expect(screen.getByTestId('docs-child')).toBeInTheDocument();
    });
  });

  describe('Page (SlugPage)', () => {
    it('renders documentation page when page exists', async () => {
      const mockMDX = () => <div data-testid="mdx-content">MDX Text</div>;
      mockGetPage.mockReturnValue({
        data: {
          title: 'Introduction',
          description: 'Getting started guide',
          body: mockMDX,
          toc: [],
          full: false,
        },
      });

      const page = await Page({
        params: Promise.resolve({ lang: 'en', slug: ['intro'] }),
      });
      render(page);

      expect(screen.getByRole('heading', { level: 1, name: 'Introduction' })).toBeInTheDocument();
      expect(screen.getByText('Getting started guide')).toBeInTheDocument();
      expect(screen.getByTestId('mdx-content')).toBeInTheDocument();
    });

    it('triggers notFound() when page is null', async () => {
      mockGetPage.mockReturnValue(null);
      await expect(
        Page({
          params: Promise.resolve({ lang: 'en', slug: ['invalid-page'] }),
        })
      ).rejects.toThrow('NEXT_NOT_FOUND');
      expect(mockNotFound).toHaveBeenCalled();
    });

    it('returns static params from source generator', async () => {
      const params = await docsStaticParams();
      expect(params).toEqual([{ lang: 'en', slug: ['intro'] }]);
    });
  });
});
