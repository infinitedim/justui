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
const mockRedirect = vi.fn();
(globalThis as any).mockNotFound = mockNotFound;
(globalThis as any).mockRedirect = mockRedirect;
vi.mock('next/navigation', () => ({
  usePathname: () => '/id',
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
    prefetch: vi.fn(),
  }),
  notFound: () => {
    mockNotFound();
    throw new Error('NEXT_NOT_FOUND');
  },
  redirect: (url: string) => {
    mockRedirect(url);
    throw new Error(`NEXT_REDIRECT:${url}`);
  },
}));

// Mock next/link
vi.mock('next/link', () => ({
  default: ({ children, href }: { children: ReactNode; href: string }) => (
    <a href={href}>{children}</a>
  ),
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
const mockGenerateParams = vi
  .fn()
  .mockReturnValue([{ lang: 'en', slug: ['intro'] }]);
(globalThis as any).mockGetPage = mockGetPage;
(globalThis as any).mockGenerateParams = mockGenerateParams;
vi.mock('@/lib/source', () => ({
  source: {
    pageTree: {
      id: {},
      en: {},
    },
    getPage: (slug: Array<string>, lang: string) => mockGetPage(slug, lang),
    generateParams: () => mockGenerateParams(),
  },
}));

// Imports of pages and layouts
import RootLayout from '@/app/layout';
import LangLayout from '@/app/[lang]/layout';
import {
  generateStaticParams as homeStaticParams,
} from '@/app/[lang]/page';
import ComponentsPage, {
  generateStaticParams as componentsStaticParams,
} from '@/app/[lang]/components/page';
import Layout from '@/app/[lang]/docs/layout';
import Page, {
  generateStaticParams as docsStaticParams,
} from '@/app/[lang]/docs/[[...slug]]/page';
import {
  LandingTemplate,
  CatalogTemplate,
  StudioTemplate,
} from '@/components/templates';
import { usePreset } from '@/components/providers';

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

    it('provides PresetProvider context to child components', () => {
      function Consumer() {
        const { preset } = usePreset();
        return <div data-testid="preset-val">{preset}</div>;
      }
      render(
        <RootLayout>
          <Consumer />
        </RootLayout>
      );
      expect(screen.getByTestId('preset-val')).toHaveTextContent('default');
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

  describe('HomePage', () => {
    it('returns static params for all supported languages', async () => {
      const params = await homeStaticParams();
      expect(params).toEqual([{ lang: 'en' }, { lang: 'id' }]);
    });
  });

  describe('ComponentsPage', () => {
    it('renders components catalog and footer correctly', async () => {
      const page = await ComponentsPage({
        params: Promise.resolve({ lang: 'en' }),
      });
      render(page);
      expect(
        screen.getByRole('heading', { level: 1, name: 'Components' })
      ).toBeInTheDocument();
      expect(screen.getByText('JustButton')).toBeInTheDocument();
      expect(
        screen.getByRole('contentinfo', { name: /site footer/i })
      ).toBeInTheDocument();
    });

    it('returns static params', async () => {
      const params = await componentsStaticParams();
      expect(params).toEqual([{ lang: 'id' }, { lang: 'en' }]);
    });
  });

  describe('Templates', () => {
    describe('LandingTemplate', () => {
      it('renders all structural slots correctly', () => {
        render(
          <LandingTemplate
            navbar={<div data-testid="landing-navbar" />}
            hero={<div data-testid="landing-hero" />}
            installStrip={<div data-testid="landing-install-strip" />}
            bentoGrid={<div data-testid="landing-bento-grid" />}
            componentShowcase={<div data-testid="landing-component-showcase" />}
            footer={<div data-testid="landing-footer" />}
          />
        );

        expect(screen.getByTestId('landing-navbar')).toBeInTheDocument();
        expect(screen.getByTestId('landing-hero')).toBeInTheDocument();
        expect(screen.getByTestId('landing-install-strip')).toBeInTheDocument();
        expect(screen.getByTestId('landing-bento-grid')).toBeInTheDocument();
        expect(
          screen.getByTestId('landing-component-showcase')
        ).toBeInTheDocument();
        expect(screen.getByTestId('landing-footer')).toBeInTheDocument();
      });

      it('renders workbench slot when provided', () => {
        render(
          <LandingTemplate
            navbar={<div data-testid="landing-navbar" />}
            hero={<div data-testid="landing-hero" />}
            workbench={<div data-testid="landing-workbench" />}
            installStrip={<div data-testid="landing-install-strip" />}
            bentoGrid={<div data-testid="landing-bento-grid" />}
            componentShowcase={<div data-testid="landing-component-showcase" />}
            footer={<div data-testid="landing-footer" />}
          />
        );

        expect(screen.getByTestId('landing-workbench')).toBeInTheDocument();
      });
    });

    describe('CatalogTemplate', () => {
      it('renders all structural slots correctly', () => {
        render(
          <CatalogTemplate
            navbar={<div data-testid="catalog-navbar" />}
            header={<div data-testid="catalog-header" />}
            catalog={<div data-testid="catalog-content" />}
            footer={<div data-testid="catalog-footer" />}
          />
        );

        expect(screen.getByTestId('catalog-navbar')).toBeInTheDocument();
        expect(screen.getByTestId('catalog-header')).toBeInTheDocument();
        expect(screen.getByTestId('catalog-content')).toBeInTheDocument();
        expect(screen.getByTestId('catalog-footer')).toBeInTheDocument();
      });
    });

    describe('StudioTemplate', () => {
      it('renders all structural slots correctly', () => {
        render(
          <StudioTemplate
            navbar={<div data-testid="studio-navbar" />}
            studioContent={<div data-testid="studio-content" />}
            footer={<div data-testid="studio-footer" />}
          />
        );

        expect(screen.getByTestId('studio-navbar')).toBeInTheDocument();
        expect(screen.getByTestId('studio-content')).toBeInTheDocument();
        expect(screen.getByTestId('studio-footer')).toBeInTheDocument();
      });
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

      expect(
        screen.getByRole('heading', { level: 1, name: 'Introduction' })
      ).toBeInTheDocument();
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

    it('redirects to introduction when slug is empty or undefined', async () => {
      await expect(
        Page({
          params: Promise.resolve({ lang: 'en', slug: [] }),
        })
      ).rejects.toThrow('NEXT_REDIRECT:/en/docs/introduction');
      expect(mockRedirect).toHaveBeenCalledWith('/en/docs/introduction');

      await expect(
        Page({
          params: Promise.resolve({ lang: 'id', slug: undefined }),
        })
      ).rejects.toThrow('NEXT_REDIRECT:/id/docs/introduction');
      expect(mockRedirect).toHaveBeenCalledWith('/id/docs/introduction');
    });

    it('returns static params from source generator', async () => {
      const params = await docsStaticParams();
      expect(params).toEqual([{ lang: 'en', slug: ['intro'] }]);
    });
  });
});
